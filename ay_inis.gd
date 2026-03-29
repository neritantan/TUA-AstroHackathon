extends RigidBody2D

# --- AY VE MEKİK PARAMETRELERİ ---
@export var ay_yercekimi_carpani: float = 0.16 
@export var max_itki: float = 350.0 
@export var donus_torku: int = 150 

# --- İNİŞ LİMİTLERİ ---
@export var max_inis_hizi: float = 25.0 
@export var hiz_katsayisi: float = 20.0

# --- YENİ EKLENENLER: HEDEF PİST SİSTEMİ ---
@export var inis_alani: Node2D         # Sahnendeki İniş Pisti düğümü
@export var hedef_oku: Sprite2D        # Mekiğin içindeki ok Sprite'ı
@export var hedef_mesafe_yazisi: Label # Kalan metreyi yazacağımız UI Label

@export var ana_govde_sprite: Sprite2D
@export var gaz_gostergesi: ProgressBar
@export var aci_gostergesi: TextureRect
@export var aci_yazisi_label: Label
@export var alev_efekti: CPUParticles2D
@export var motor_sesi: AudioStreamPlayer2D
@export var kamera: Camera2D
@export var yakit_gostergesi: ProgressBar
@export var hiz_yazisi_label: Label
@export var yukseklik_yazisi_label: Label
@export var patlama_efekti: AnimatedSprite2D
@export var patlama_sesi: AudioStreamPlayer2D
@export var aslinin_ekrani: CanvasLayer

var baslangic_y = 0.0
var guncel_yakit = 100.0
var guncel_throttle = 0.0
var oyun_aktif = true
var oyun_bitti_basarili = false

var egitim_asamalari = { "giris": false, "yakit_az": false }
var aslinin_replikleri = {
	"giris": "ASLI: Hedefe yaklaştık! Atmosfer yok, sürtünme yok. Radarındaki oku takip et ve belirlenen iniş pistine yönel. Ay yüzeyi çok engebelidir, pist dışına inersen modül devrilir!",
	"yakit_az": "ASLI: Komutanım dikkat! Yakıt kritik seviyede. İnişi hızlandırman gerek, yoksa taş gibi düşeriz!",
	"gorev_basarili": "ASLI: Kartal kondu! Kusursuz bir inişti komutanım. TUA seninle gurur duyuyor!",
	"gorev_basarisiz_carpisma": "ASLI: Sinyal koptu... Modül yüzeye çakıldı! İniş hızın çok yüksekti veya yere yamuk çarptın. Ay'da hava yastığı yok. [C] tuşu ile tekrar dene!",
	"gorev_basarisiz_yakit": "ASLI: Yakıt tamamen bitti ve yüzeye çakıldık. İticileri daha idareli kullanmalıydın. [C] tuşu ile tekrar dene!",
	"gorev_basarisiz_yanlis_yer": "ASLI: Sinyal koptu... Pisti ıskalayıp kayalıklara indin! Yüzey engebeli olduğu için modül devrilip parçalandı. Oku takip et ve sadece piste in! [C] tuşu ile tekrar dene!"
}

func _ready():
	baslangic_y = global_position.y
	mass = 0.8 
	gravity_scale = ay_yercekimi_carpani 
	
	linear_damp = 0.0
	angular_damp = 0.0
	
	if patlama_efekti != null: patlama_efekti.hide()
	if patlama_sesi != null: patlama_sesi.stop()

	contact_monitor = true
	max_contacts_reported = 5
	body_entered.connect(_yere_carpti)

func _physics_process(delta):
	if oyun_bitti_basarili and not get_tree().paused:
		if Input.is_action_just_pressed("ui_accept"):
			pass # Sonraki bölüm kodu

	if not oyun_aktif and Input.is_action_just_pressed("ui_accept"): 
		get_tree().reload_current_scene()
		return
	if not oyun_aktif: return

	if aslinin_ekrani != null:
		if not egitim_asamalari["giris"]:
			egitim_asamalari["giris"] = true
			aslinin_ekrani.konus(aslinin_replikleri["giris"])
		if guncel_yakit < 30.0 and guncel_yakit > 0 and not egitim_asamalari["yakit_az"]:
			egitim_asamalari["yakit_az"] = true
			aslinin_ekrani.konus(aslinin_replikleri["yakit_az"])

	# --- HEDEF OKU VE MESAFE HESABI ---
	if inis_alani != null:
		# Piste olan yönü ve mesafeyi hesapla
		var yon_vektoru = inis_alani.global_position - global_position
		var mesafe = yon_vektoru.length() / 10.0 # Pikselleri metreye çeviriyoruz
		
		if hedef_mesafe_yazisi != null:
			hedef_mesafe_yazisi.text = "Piste Uzaklık: " + str(round(mesafe)) + " m"
			
		if hedef_oku != null:
			# Okun her zaman piste bakmasını sağla (global_rotation kullandığımız için roket dönse de ok şaşmaz)
			# Not: Eğer ok görselin varsayılan olarak YUKARI bakıyorsa + (PI/2) eklemen gerekebilir. Sağa bakıyorsa tam oturur.
			hedef_oku.global_rotation = yon_vektoru.angle() + (PI/2) 

	# --- THROTTLE VE YAKIT ---
	if guncel_yakit > 0.0:
		if Input.is_action_pressed("ui_up"): guncel_throttle += 0.6 * delta
		elif Input.is_action_pressed("ui_down"): guncel_throttle -= 0.8 * delta
	else:
		guncel_throttle -= 2.0 * delta
	guncel_throttle = clamp(guncel_throttle, 0.0, 1.0)

	guncel_yakit -= (guncel_throttle * 2.5) * delta
	guncel_yakit = clamp(guncel_yakit, 0.0, 100.0)

	# --- HAREKET ---
	var donus_yonu = 0
	if Input.is_action_pressed("ui_right"): donus_yonu += 1
	elif Input.is_action_pressed("ui_left"): donus_yonu -= 1

	var roketin_baktigi_yon = Vector2.UP.rotated(rotation)
	apply_central_force(roketin_baktigi_yon * (max_itki * guncel_throttle))
	apply_torque(donus_yonu * donus_torku) 

	# --- ARAYÜZ (UI) GÜNCELLEMELERİ ---
	if gaz_gostergesi != null: gaz_gostergesi.value = guncel_throttle * 100
	if yakit_gostergesi != null: yakit_gostergesi.value = guncel_yakit
	if aci_gostergesi != null: aci_gostergesi.rotation = rotation
	
	var gercek_aci = 90 - abs(round(rad_to_deg(rotation)))
	if aci_yazisi_label != null: aci_yazisi_label.text = "Açı: " + str(gercek_aci) + "°"
	
	var dikey_hiz = round(linear_velocity.y / 10.0 * hiz_katsayisi)
	if hiz_yazisi_label != null: hiz_yazisi_label.text = "Düşüş Hızı: " + str(dikey_hiz) + " m/s"

	# --- EFEKTLER ---
	if alev_efekti != null:
		alev_efekti.emitting = (guncel_throttle > 0.0)
		alev_efekti.scale = Vector2(1.5, 1.5) * (0.5 + guncel_throttle * 0.5)

	if motor_sesi != null:
		if guncel_throttle > 0.0:
			if not motor_sesi.playing: motor_sesi.play()
			motor_sesi.volume_db = lerp(-20.0, 0.0, guncel_throttle)
			motor_sesi.pitch_scale = lerp(0.8, 1.5, guncel_throttle)
		else:
			motor_sesi.stop()

func _yere_carpti(body):
	if not oyun_aktif: return
	
	var inis_hizi = linear_velocity.y / 10.0 * hiz_katsayisi
	var gercek_aci = 90 - abs(round(rad_to_deg(rotation)))
	
	# 1. Kontrol: Yere çarptığımız obje "inis_alani" grubunda mı?
	var piste_indi_mi = body.is_in_group("inis_alani")
	
	if inis_hizi > max_inis_hizi or gercek_aci < 80 or gercek_aci > 100:
		roket_patlat("carpisma")
	elif not piste_indi_mi:
		roket_patlat("yanlis_yer")
	else:
		_basarili_inis_sekansi()

func _basarili_inis_sekansi():
	oyun_aktif = false
	guncel_throttle = 0.0
	if alev_efekti != null: alev_efekti.emitting = false
	if motor_sesi != null: motor_sesi.stop()
	if hedef_oku != null: hedef_oku.hide() # İndik artık ok gitsin
	
	await get_tree().create_timer(1.5).timeout
	
	oyun_bitti_basarili = true
	if aslinin_ekrani != null: aslinin_ekrani.konus(aslinin_replikleri["gorev_basarili"])

func roket_patlat(sebep = "genel"):
	if not oyun_aktif: return
	oyun_aktif = false
	
	if ana_govde_sprite != null: ana_govde_sprite.hide()
	if alev_efekti != null: alev_efekti.emitting = false
	if motor_sesi != null: motor_sesi.stop()
	if hedef_oku != null: hedef_oku.hide()
	
	if patlama_efekti != null:
		patlama_efekti.show()
		patlama_efekti.play("default")
	if patlama_sesi != null: patlama_sesi.play()

	await get_tree().create_timer(1.0).timeout

	if aslinin_ekrani != null:
		if sebep == "yanlis_yer":
			aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_yanlis_yer"])
		elif guncel_yakit <= 0:
			aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_yakit"])
		else:
			aslinin_ekrani.konus(aslinin_replikleri["gorev_basarisiz_carpisma"])
