extends RigidBody2D

# --- YÖRÜNGE HIZ LİMİTLERİ ---
# hiz_katsayisi = 20: linear_velocity ~3500 px/s → gosterge 7000 m/s
# linear_velocity ~4750 px/s → gosterge 9500 m/s
@export var hiz_katsayisi: float = 20.0
@export var min_yorunge_hizi: float = 7000.0
@export var max_yorunge_hizi: float = 9500.0

# --- ROKET PARAMETRELERİ ---
# mass=2.0, gravity=980 → yerçekimi kuvveti=1960
# max_itki=3000 → TWR = 3000/1960 = 1.53 (gerçekçi, Falcon 9 ~1.3-1.5)
var max_itki = 3000
# Staging sonrası ana motor: boosterlar gitti, kütle 1.0'a indi
# 3000*0.58 = 1740 → TWR = 1740/980 = 1.77 (hafifleyince daha çevik, doğru)
var ana_motor_itkisi: float = 1740.0

@export var ana_govde_sprite: Sprite2D
@export var gaz_gostergesi: ProgressBar
@export var aci_gostergesi: TextureRect
@export var aci_yazisi_label: Label
@export var alev_efekti: CPUParticles2D
@export var duman_efekti: CPUParticles2D
@export var motor_sesi: AudioStreamPlayer2D
@export var kamera: Camera2D
@export var yakit_gostergesi: ProgressBar
@export var hiz_yazisi_label: Label
@export var yukseklik_yazisi_label: Label

@export var stres_gostergesi: ProgressBar
@export var patlama_efekti: AnimatedSprite2D
@export var patlama_sesi: AudioStreamPlayer2D

@export var uyari_yazisi_label: Label
@export var sol_booster_sprite: Sprite2D
@export var sag_booster_sprite: Sprite2D

# YENİ EKLENEN DEĞİŞKENLER (Jiroskop ve Tork için)
@export var cursor_sprite: CanvasItem 
var uzay_tork_carpani: float = 0.3 

var kademe_ayrildi_mi = false

var uzay_kararma_baslangic: float = 50000.0
var yildiz_belirme_baslangic: float = 80000.0
var karman_hatti_irtifasi: float = 100000.0

@export var aslinin_ekrani: CanvasLayer
@export var gokyuzu_layer: ParallaxLayer
@export var yildizlar_layer: ParallaxLayer

var oyun_basarili_bitti = false
var oyun_basarisiz_bitti = false

var egitim_asamalari = {
	"giris": false, "kalkis": false, "max_q": false,
	"uzay_kararma": false, "yildizlar": false, "gravity_turn": false,
	"staging": false, "uzay": false, "gorev_basarili": false
}

var aslinin_replikleri = {
	"giris": "ASLI: TUA Görev Kontrol'den merhaba! Ben Uçuş Direktörü Aslı. Bugünkü fırlatmadan ben sorumluyum. Görevin, bu devasa roketi sağ salim uzaya çıkarmak. Endişelenme, her kritik aşamada sistemleri dondurup sana ne yapman gerektiğini söyleyeceğim. Hazırsan başlayalım!",
	"kalkis": "ASLI: 10.000 metreyi geçtik! Bak, altındaki o devasa gövdenin %90'ı sadece yakıt. Neden mi? Çünkü Dünya seni bırakmak istemiyor. Yerçekimi seni saniyede 9.8 metre hızla aşağı çekiyor. Motorları ateşle ama yakıtını idareli kullan; biterse taş gibi düşeriz!",
	"max_q": "ASLI: Ekranın titremesine şaşırma, şu an havayı adeta bir duvar gibi delip geçiyoruz! Max-Q denilen bölgedeyiz. Rüzgarın rokete bindirdiği yük şu an zirvede. Eğer gaz kesmezsen roket bu basınca dayanamaz, kağıt gibi yırtılır! Gazı hemen %80-85 arasına çek, roket nefes alsın!",
	"uzay_kararma": "ASLI: 50.000 metreyi devirdik! Atmosfer bitiyor, gökyüzü kararıyor. Bak, yıldızlar bile belirmeye başladı. Fizik kuralları değişmek üzere, hazır ol astronot!",
	"yildizlar": "ASLI: 80.000 metreyi geçtik, artık tam uzaydayız! Yerçekimi neredeyse sıfırlandı, hava direnci bitti. Artık Newton'un eylemsizlik yasasındayız; gaza basmasan bile aynı hızla kayarsın. TUA gurur duyuyor!",
	"gravity_turn": "ASLI: Yükseliyoruz ama sadece yukarı çıkarsan mermi gibi geri düşersin! Uzayda kalmak demek, yere düşmeyecek kadar hızlı YAN GİTMEK demektir. Burnunu yavaşça 45 derece sağa yatır. Dünyanın kavisini takip et, yerçekimini yen!",
	"staging": "ASLI: Tanklardaki yakıt bitiyor! İçinde yakıt olmayan bir tank, bizi yavaşlatan devasa bir metal çöpüdür. Onlarla uzaya varamayız. [SPACE] tuşuna bas ve onlardan kurtul! Ölü ağırlığı atarsan nasıl şahlandığını göreceksin!",
	"uzay": "ASLI: Gözlerini aç, atmosfer bitti! Karman Hattı'nı geçtik. Yörüngeye sorunsuz oturmak için hızını 7.000 ile 9.500 m/s arasında tutman lazım. Çok yavaşlarsan Dünya'ya düşeriz, çok hızlanırsan uzayda kayboluruz! Hızını bu aralıkta sabitle ve 200.000 metreye kadar süzül!",
	"gorev_basarili": "ASLI: İnanılmaz! 200.000 metrede mükemmel yörünge açısını ve hedeflenen hızı yakaladın. Motorları kapat, yörüngeye oturduk! TUA seninle gurur duyuyor, görev başarıyla tamamlandı.",
	"gorev_basarisiz_stres": "ASLI: Sinyal koptu... Roket aerodinamik basınca dayanamadı ve havada parçalandı! Atmosferin kalın olduğu Max-Q bölgesinde tam gaz gitmek intihardır. Bir dahaki sefere ekran titrediğinde gazı kısmayı unutma. Yeniden denemek için [C] tuşuna bas!",
	"gorev_basarisiz_carpisma": "ASLI: Sinyal koptu... Roket yere çakıldı! Bu bir uçak değil, iniş takımlarımız yok. Kalkışta yeterince hızlanamamış veya yörünge dönüşünü çok yanlış bir açıyla yapmış olabilirsin. Yerçekimine yenilme. Yeniden denemek için [C] tuşuna bas!",
	"gorev_basarisiz_yorunge": "ASLI: Hedef irtifaya ulaştın ama yörünge açın felaket! Bu açıyla Dünya'nın etrafında dönemeyiz, ya taş gibi geri düşeceğiz ya da derin uzayda kaybolacağız. 45 derece kuralını unuttun mu? Görev iptal... Yeniden denemek için [C] tuşuna bas!",
	"gorev_basarisiz_yakit_bitti": "ASLI: Sinyal koptu... Yakıt tankları tamamen boş! 20.000 metrenin üzerinde motorlar susarsa yörüngeye giremeyiz ve taş gibi geri düşeriz. Yakıtı bu kadar hoyratça harcamamalıydın! Yeniden denemek için [C] tuşuna bas!",
	"gorev_basarisiz_yavas": "ASLI: Görev iptal... Hedef irtifadayız ama hızımız yörüngeye oturmak için çok düşüktü! Merkezkaç kuvveti yetersiz kaldı ve Dünya'nın yerçekimine yenik düştük. Daha fazla hızlanmalıydın. Yeniden denemek için [C] tuşuna bas!",
	"gorev_basarisiz_hizli": "ASLI: Sinyal zayıflıyor... Çok hızlıyız! Yörüngeye oturmak yerine Dünya'nın kütleçekiminden tamamen koptuk ve derin uzayda kaybolduk. Motorları daha erken kapatmalıydın! Yeniden denemek için [C] tuşuna bas!",
	"gorev_basarisiz_genel": "ASLI: Sinyal koptu... Roketi kaybettik! Görev başarısız oldu komutanım. Ama uzay araştırmaları deneme yanılma işidir, pes etmek yok. Yeniden denemek için [C] tuşuna bas!"
}

var baslangic_y = 0.0
var guncel_yakit = 100.0
var guncel_throttle = 0.0
var donus_torku = 800
var guncel_stres = 0.0
var max_stres = 100.0
var stres_artis_hizi = 30.0
var oyun_aktif = true

func _ready():
	baslangic_y = global_position.y
	mass = 2.0

	linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE

	if uyari_yazisi_label != null: uyari_yazisi_label.hide()
	if patlama_efekti != null: patlama_efekti.hide()
	if patlama_sesi != null: patlama_sesi.stop()
	if yildizlar_layer != null: yildizlar_layer.modulate.a = 0.0

	contact_monitor = true
	max_contacts_reported = 5
	body_entered.connect(_yere_carpti)

func _physics_process(delta):
	if oyun_basarili_bitti and not get_tree().paused:
		get_tree().change_scene_to_file("res://Bolum2.tscn")
		return
	if oyun_basarisiz_bitti and not get_tree().paused:
		get_tree().reload_current_scene()
		return
	if not oyun_aktif:
		return

	var yukseklik = round(baslangic_y - global_position.y)
	if yukseklik < 0: yukseklik = 0

	# --- SİNEMATİK GEÇİŞ ---
	if gokyuzu_layer != null:
		gokyuzu_layer.modulate.a = clamp(remap(yukseklik, uzay_kararma_baslangic, karman_hatti_irtifasi, 1.0, 0.0), 0.0, 1.0)
	if yildizlar_layer != null:
		yildizlar_layer.modulate.a = clamp(remap(yukseklik, yildiz_belirme_baslangic, karman_hatti_irtifasi, 0.0, 1.0), 0.0, 1.0)

	# --- FİZİK: ATMOSFER VE YERÇEKİMİ ---
	if yukseklik >= karman_hatti_irtifasi:
		gravity_scale = 0.0
		linear_damp = 0.0
		angular_damp = 0.0
	else:
		var atmosfer_kalinligi = clamp(1.0 - (yukseklik / karman_hatti_irtifasi), 0.0, 1.0)
		# HESAPLANDI: linear_damp=1.0 → terminal hız≈3000 px/s → gosterge≈6000 m/s (karman öncesi)
		# Bu tam istediğimiz: karman'da 5000-6000, uzayda 7000-9500'e çıkılabilir
		linear_damp = 1.0 * atmosfer_kalinligi
		angular_damp = 3.0 * atmosfer_kalinligi
		if yukseklik > uzay_kararma_baslangic:
			gravity_scale = clamp(1.0 - ((yukseklik - uzay_kararma_baslangic) / (karman_hatti_irtifasi - uzay_kararma_baslangic)), 0.0, 1.0)
		else:
			gravity_scale = 1.0

	# --- THROTTLE ---
	if guncel_yakit > 0.0:
		if Input.is_action_pressed("ui_up"): guncel_throttle += 0.25 * delta
		elif Input.is_action_pressed("ui_down"): guncel_throttle -= 0.5 * delta
	else:
		guncel_throttle -= 1.0 * delta
	guncel_throttle = clamp(guncel_throttle, 0.0, 1.0)

	# --- YAKIT TÜKETİMİ ---
	# HESAPLANDI: Normal tüketim 0.5/s → 100 birim yakıt ≈ 200 saniye sürer (tam gaz değilken)
	# >%85 throttle: 3.0/s → agresif gaz yakıtı 33 saniyede eritir (gerçekçi ceza)
	var anlik_tuketim_hizi = 0.8
	if guncel_throttle > 0.85: anlik_tuketim_hizi = 4.5
	guncel_yakit -= (guncel_throttle * anlik_tuketim_hizi) * delta
	guncel_yakit = clamp(guncel_yakit, 0.0, 100.0)

	if yukseklik > 20000 and guncel_yakit <= 0.0 and yukseklik < 200000:
		roket_patlat("yakit_bitti")

	# --- BOOSTER ALEV EFEKTLERİ ---
	if not kademe_ayrildi_mi:
		for booster in [sol_booster_sprite, sag_booster_sprite]:
			if booster == null: continue
			var alev = booster.get_node_or_null("EgzozEfekt")
			if alev == null: continue
			var uzay_f = clamp(1.0 - (yukseklik / karman_hatti_irtifasi), 0.0, 1.0) if yukseklik < karman_hatti_irtifasi else 0.0
			alev.scale = Vector2(lerp(1.0, 2.0, uzay_f), 1.0)
			alev.emitting = (guncel_throttle >= 0.79)

	# --- STAGING UYARISI ---
	if guncel_yakit <= 80.0 and not kademe_ayrildi_mi:
		if uyari_yazisi_label != null:
			uyari_yazisi_label.show()
			uyari_yazisi_label.text = "AYRILMA İÇİN BOŞLUK (SPACE) TUŞUNA BAS!"
		if Input.is_action_just_pressed("ui_accept"): ayrilma_tetikle()

	# --- MAX-Q STRESİ ---
	if yukseklik < 12000 and guncel_throttle > 0.85:
		guncel_stres += stres_artis_hizi * delta
	else:
		guncel_stres -= (stres_artis_hizi / 2.0) * delta
	guncel_stres = clamp(guncel_stres, 0.0, 100.0)
	if stres_gostergesi != null: stres_gostergesi.value = guncel_stres
	if guncel_stres >= max_stres: roket_patlat("stres")

	# --- HAREKET ---
	var donus_yonu = 0
	if Input.is_action_pressed("ui_right"): donus_yonu += 1
	elif Input.is_action_pressed("ui_left"): donus_yonu -= 1

	var roketin_baktigi_yon = Vector2.UP.rotated(rotation)
	apply_central_force(roketin_baktigi_yon * (max_itki * guncel_throttle))
	
	# YENİ EKLENEN KISIM: Yüksekliğe göre Tork Ayarı
	var aktif_tork = donus_torku
	if yukseklik > 30000:
		aktif_tork = donus_torku * uzay_tork_carpani
		
	apply_torque(donus_yonu * aktif_tork)

	if yukseklik < karman_hatti_irtifasi:
		var roketin_yani = Vector2.RIGHT.rotated(rotation)
		var yana_kayma = linear_velocity.dot(roketin_yani)
		var atmosfer_k = clamp(1.0 - (yukseklik / karman_hatti_irtifasi), 0.0, 1.0)
		apply_central_force(-roketin_yani * (yana_kayma * 5.0 * atmosfer_k))

	# --- GÖSTERGELER ---
	if gaz_gostergesi != null: gaz_gostergesi.value = guncel_throttle * 100
	if yakit_gostergesi != null: yakit_gostergesi.value = guncel_yakit
	if aci_gostergesi != null: aci_gostergesi.rotation = rotation
	
	var gercek_aci = 90 - abs(round(rad_to_deg(rotation)))
	if aci_yazisi_label != null:
		aci_yazisi_label.text = "Açı: " + str(gercek_aci) + "°"

	# YENİ EKLENEN KISIM: 30.000 metre sonrası Cursor Renklendirme
	if cursor_sprite != null:
		if yukseklik > 30000 and gercek_aci >= 43 and gercek_aci <= 47:
			cursor_sprite.modulate = Color(0, 1, 0) # Yeşil
		else:
			cursor_sprite.modulate = Color(1, 1, 1) # Beyaz

	# --- ALEV VE DUMAN EFEKTLERİ ---
	if alev_efekti != null and duman_efekti != null:
		alev_efekti.emitting = (guncel_throttle > 0.0)
		var uzay_f = clamp(1.0 - (yukseklik / karman_hatti_irtifasi), 0.0, 1.0) if yukseklik < karman_hatti_irtifasi else 0.0
		alev_efekti.scale = Vector2(lerp(1.0, 3.0, uzay_f), 1.0) * (0.2 + guncel_throttle * 0.8)
		duman_efekti.emitting = (guncel_throttle > 0.8) and (yukseklik < karman_hatti_irtifasi / 2.0)

	# --- MOTOR SESİ ---
	if motor_sesi != null:
		if guncel_throttle > 0.0:
			if not motor_sesi.playing: motor_sesi.play()
			var uzay_f = clamp(1.0 - (yukseklik / karman_hatti_irtifasi), 0.0, 1.0) if yukseklik < karman_hatti_irtifasi else 0.0
			motor_sesi.volume_db = lerp(-20.0, lerp(-20.0, 0.0, uzay_f), guncel_throttle)
			motor_sesi.pitch_scale = lerp(0.5, 1.2, guncel_throttle)
		else:
			motor_sesi.stop()

	# --- KAMERA TİTREŞİMİ ---
	if kamera != null:
		var titresim = 0.0
		if yukseklik < karman_hatti_irtifasi and guncel_throttle > 0.85:
			var atm = clamp(1.0 - (yukseklik / karman_hatti_irtifasi), 0.0, 1.0)
			titresim = (guncel_throttle - 0.85) * 100.0 * atm
		if guncel_stres > 10.0: titresim += (guncel_stres / 2.0)
		if titresim > 0.0:
			kamera.offset = Vector2(0, -200) + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * titresim
		else:
			kamera.offset = Vector2(0, -200)

	# --- HIZ HESABI ---
	var gosterge_hizi = round((linear_velocity.length() / 10.0) * hiz_katsayisi)

	if hiz_yazisi_label != null: hiz_yazisi_label.text = "Hız: " + str(gosterge_hizi) + " m/s"
	if yukseklik_yazisi_label != null: yukseklik_yazisi_label.text = "İrtifa: " + str(yukseklik) + " m"

	# --- ASLI TETİKLEMELERİ ---
	if aslinin_ekrani != null:
		if not egitim_asamalari["giris"]:
			egitim_asamalari["giris"] = true
			aslinin_ekrani.konus(aslinin_replikleri["giris"])
		if yukseklik > 7000 and not egitim_asamalari["kalkis"]:
			egitim_asamalari["kalkis"] = true
			aslinin_ekrani.konus(aslinin_replikleri["kalkis"])
		if guncel_stres > 40.0 and not egitim_asamalari["max_q"]:
			egitim_asamalari["max_q"] = true
			aslinin_ekrani.konus(aslinin_replikleri["max_q"])
		if yukseklik > uzay_kararma_baslangic and not egitim_asamalari["uzay_kararma"]:
			egitim_asamalari["uzay_kararma"] = true
			aslinin_ekrani.konus(aslinin_replikleri["uzay_kararma"])
		if yukseklik > 30000 and not egitim_asamalari["gravity_turn"]:
			egitim_asamalari["gravity_turn"] = true
			aslinin_ekrani.konus(aslinin_replikleri["gravity_turn"])
		if guncel_yakit <= 80.0 and not egitim_asamalari["staging"]:
			egitim_asamalari["staging"] = true
			aslinin_ekrani.konus(aslinin_replikleri["staging"])
		if yukseklik > karman_hatti_irtifasi - 30000 and not egitim_asamalari["uzay"]:
			egitim_asamalari["uzay"] = true
			aslinin_ekrani.konus(aslinin_replikleri["uzay"])

		# --- BÜYÜK FİNAL: 200.000 Metre + Açı + Hız Kontrolü ---
		if yukseklik >= 200000 and not egitim_asamalari["gorev_basarili"]:
			egitim_asamalari["gorev_basarili"] = true
			var suanki_aci = 90 - abs(round(rad_to_deg(rotation)))
			if suanki_aci >= 43 and suanki_aci <= 47:
				if gosterge_hizi < min_yorunge_hizi:
					roket_patlat("yavas")
				elif gosterge_hizi > max_yorunge_hizi:
					roket_patlat("hizli")
				else:
					oyun_basarili_bitti = true
					aslinin_ekrani.konus(aslinin_replikleri["gorev_basarili"])
			else:
				roket_patlat("yorunge")


func _yere_carpti(body):
	if not oyun_aktif: return
	if body.is_in_group("kendi_parcam"): return
	var hiz = linear_velocity.length() / 10.0
	var gercek_aci = 90 - abs(round(rad_to_deg(rotation)))
	if hiz > 10.0 or gercek_aci < 88 or gercek_aci > 92:
		roket_patlat("carpisma")


func roket_patlat(sebep = "genel"):
	if not oyun_aktif: return
	oyun_aktif = false
	set_deferred("freeze", true)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	if ana_govde_sprite != null: ana_govde_sprite.hide()
	if get_node_or_null("anaroket") != null: get_node("anaroket").hide()
	if sol_booster_sprite != null: sol_booster_sprite.hide()
	if sag_booster_sprite != null: sag_booster_sprite.hide()
	if kamera != null: kamera.offset = Vector2(0, -200)
	if motor_sesi != null: motor_sesi.stop()
	if alev_efekti != null:
		alev_efekti.emitting = false
		alev_efekti.hide()
	if duman_efekti != null:
		duman_efekti.emitting = false
		duman_efekti.hide()
	if patlama_efekti != null:
		patlama_efekti.show()
		patlama_efekti.play("default")
	if patlama_sesi != null: patlama_sesi.play()

	await get_tree().create_timer(1.5).timeout

	if aslinin_ekrani != null and not oyun_basarisiz_bitti:
		oyun_basarisiz_bitti = true
		if sebep == "stres": aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_stres"])
		elif sebep == "carpisma": aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_carpisma"])
		elif sebep == "yorunge": aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_yorunge"])
		elif sebep == "yakit_bitti": aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_yakit_bitti"])
		elif sebep == "yavas": aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_yavas"])
		elif sebep == "hizli": aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_hizli"])
		else: aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_genel"])


func ayrilma_tetikle():
	kademe_ayrildi_mi = true
	if uyari_yazisi_label != null: uyari_yazisi_label.hide()

	mass = 1.0  
	max_itki = ana_motor_itkisi  

	var roketin_hizi = linear_velocity
	var roketin_donme_hizi = angular_velocity

	if sol_booster_sprite != null:
		call_deferred("_efektli_parca_yarat", sol_booster_sprite, roketin_hizi, roketin_donme_hizi)
		sol_booster_sprite.hide()
	if sag_booster_sprite != null:
		call_deferred("_efektli_parca_yarat", sag_booster_sprite, roketin_hizi, roketin_donme_hizi)
		sag_booster_sprite.hide()


func _efektli_parca_yarat(kaynak_sprite: Sprite2D, roket_hizi: Vector2, roket_donme: float):
	var test_govde = RigidBody2D.new()
	test_govde.add_to_group("kendi_parcam")
	var test_sprite = Sprite2D.new()
	test_sprite.texture = kaynak_sprite.texture
	test_sprite.scale = kaynak_sprite.scale
	test_govde.add_child(test_sprite)
	var carpisma = CollisionShape2D.new()
	var sekil = RectangleShape2D.new()
	sekil.size = kaynak_sprite.texture.get_size() * kaynak_sprite.scale
	carpisma.shape = sekil
	test_govde.add_child(carpisma)
	if duman_efekti != null:
		var yeni_puf = duman_efekti.duplicate()
		yeni_puf.show()
		yeni_puf.emitting = true
		yeni_puf.position = Vector2(0, 30)
		yeni_puf.amount = 15
		test_govde.add_child(yeni_puf)
	get_parent().add_child(test_govde)
	test_govde.global_transform = kaynak_sprite.global_transform
	test_govde.linear_velocity = roket_hizi
	test_govde.angular_velocity = roket_donme
	var yon = 1 if kaynak_sprite.position.x > 0 else -1
	test_govde.apply_impulse(Vector2(yon * 150, 0).rotated(test_govde.rotation))
