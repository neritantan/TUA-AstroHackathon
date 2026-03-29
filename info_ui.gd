extends CanvasLayer

@export var bilgi_label: Label
@export var panel_konteynir: PanelContainer

var bilgiler = [
	"Roketlerin kalkışta kullandığı devasa su kuleleri, ses dalgalarını sönümleyerek aracın kendi sesiyle parçalanmasını önler.",
	"Max-Q noktası, roketin üzerine binen aerodinamik basıncın ve rüzgar direncinin zirve yaptığı andır.",
	"Karman Hattı deniz seviyesinden 100 km yukarıda başlar ve uzayın resmi sınırı kabul edilir.",
	"Dünya yörüngesine girmek için dikey tırmanıştan ziyade saatte 28.000 km yatay hız kazanmak gerekir.",
	"Roketler Dünya'nın dönüş hızından faydalanmak için genellikle doğu yönünde fırlatılır.",
	"Ay yüzeyindeki tozlar atmosfer olmadığı için aşınmaz; cam kadar keskindir ve giysilere zarar verebilir.",
	"Ay'daki ayak izleri, rüzgar veya yağmur olmadığı için milyonlarca yıl bozulmadan kalabilir.",
	"Apollo 11'in iniş bilgisayarı, günümüzdeki bir hesap makinesinden bile daha az işlem gücüne sahipti.",
	"Yerçekimi Yardımı manevrası, bir gezegenin kütleçekimini sapan gibi kullanarak roketin hızını artırır.",
	"Bir roketin toplam kütleçekiminden kurtulması için gereken hıza 'Kaçış Hızı' denir; Dünya için bu 11.2 km/s'dir.",
	"Ay yörüngesine girerken yapılan yavaşlama yanışına 'Lunar Orbit Insertion' denir.",
	"Retrograde yanışı, roketin gidiş yönünün tersine ateş ederek hızı düşürmek için kullanılır.",
	"Prograde yanışı, yörünge hızını artırarak roketin irtifasını yükseltmek için yapılır.",
	"Roket motorları vakumda yanabilmek için hem yakıtı hem de oksitleyiciyi tanklarda taşır.",
	"Ay'ın yerçekimi Dünya'nın yaklaşık altıda biri kadardır; orada bir smaç basmak çok daha kolaydır!",
	"Uzayda sürtünme yoktur; bir kez hız kazanan cisim motoru kapatsa bile o hızla sonsuza kadar gider.",
	"Van Allen Kuşakları, Dünya'yı çevreleyen ve yüksek radyasyon içeren parçacık bölgeleridir.",
	"Aşamalı staging sistemi, boşalan ağır tankları atarak kütleyi azaltmak ve ivmeyi artırmak içindir.",
	"James Webb Uzay Teleskobu, evrenin ilk ışıklarını görebilmek için kızılötesi dalga boyunu kullanır.",
	"Ay'da atmosfer olmadığı için gökyüzü gündüz bile zifiri karanlık görünür.",
	"Gravity Turn manevrası, roketin yerçekimini kullanarak yakıt harcamadan yatay konuma geçmesini sağlar.",
	"Ay'ın karanlık yüzü aslında güneş alır, sadece Dünya'dan bakınca hep aynı yüzünü görürüz.",
	"Uzay boşluğunda sıcaklık, güneş alan yerlerde 120 derece iken gölgede -150 dereceye düşebilir.",
	"Sıvı yakıtlı roket motorları istendiğinde kapatılıp tekrar ateşlenebilir; katı yakıtlılar ise durmaz.",
	"Ay tozları astronotlar tarafından barut kokusuna benzetilmiştir.",
	"Uzay giysileri astronotları vakumdan ve saatte binlerce km hızla giden mikro meteorlardan korur.",
	"James Webb Teleskobu Dünya'dan 1.5 milyon km uzaktaki L2 noktasında sabit durur.",
	"Hohmann Transfer Yörüngesi, iki yörünge arasında en az yakıtla geçiş yapmanın en verimli yoludur.",
	"Ay ile Dünya arasındaki mesafe o kadar uzaktır ki araya tüm gezegenler yan yana sığabilir.",
	"Işık hızıyla Ay'a ulaşmak sadece 1.28 saniye sürer.",
	"Ay yörüngesinde uydular Periapsis noktasında en hızlı, Apoapsis noktasında en yavaş hareket ederler.",
	"Uzayda ağlamak zordur; gözyaşları aşağı akmaz, gözün üstünde bir su balonu gibi birikir.",
	"Astronotların boyu yerçekimsiz ortamda omurgaları gevşediği için 5 santimetreye kadar uzayabilir.",
	"Ay'ın gelgit etkisi sadece denizleri değil, Dünya'nın kabuğunu da birkaç santimetre esnetir.",
	"İlk yapay uydu Sputnik 1, bir basketbol topu büyüklüğündeydi ve sadece bip sesi çıkarıyordu.",
	"Roketlerdeki Gimbal sistemi, motorun açısını değiştirerek aracın havada yönlenmesini sağlar.",
	"Uzay çöpleri, saatte 28.000 km hızla hareket ederek küçük bir vidayı bile mermi kadar tehlikeli yapar.",
	"Ay'daki Sakinlik Denizi aslında su barındırmayan devasa bir bazalt ovasıdır.",
	"Kriyojenik yakıtlar (sıvı hidrojen ve oksijen) -250 derecelere kadar soğutulmuş halde tutulur.",
	"Yerçekimi olmayan bir ortamda mum alevi küre şeklinde ve mavi renkli yanar.",
	"Specific Impulse (Isp), bir roket motorunun yakıt verimliliğini gösteren en kritik değerdir.",
	"Ay'da su buzu, güneş görmeyen kraterlerin diplerinde kristal halde bulunur.",
	"Bir roket kalkışta yakıtının yarısını sadece ilk 30 kilometrelik yoğun atmosferi geçmek için tüketir.",
	"James Webb Teleskobu'nun güneş kalkanı bir tenis kortu büyüklüğündeydi.",
	"Apollo 17 astronotları Ay yüzeyinde bir Ay aracı ile yaklaşık 35 km yol yapmışlardır.",
	"Retro-reflektörler, Ay'a yerleştirilen aynalardır; Dünya'dan lazerle mesafe ölçülür.",
	"Lagrange Noktaları, iki gök cisminin yerçekiminin birbirini dengelediği park alanlarıdır.",
	"Uzayda paslanma olmaz çünkü demiri oksitleyecek serbest oksijen yoktur.",
	"Satürn V roketi fırlatıldığında, yakınındaki binaların camlarını kıracak kadar sarsıntı yaratıyordu.",
	"Ay yüzeyi, atmosferi olmadığı için milyarlarca yıldır meteor çarpmalarıyla delik deşik olmuştur.",
	"Tsiolkovsky'nin roket denklemi, kazanılan hızı yakıt ve kütle oranına bağlar.",
	"Ay'a yapılan insanlı uçuşlar genellikle 3 gün sürer."
]

var mevcut_indeks = 0
var gecen_sure = 0.0
var degisim_suresi = 10.0 # 10 saniyede bir aksın

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	yeni_bilgi_goster()

func _process(delta):
	if panel_konteynir != null:
		panel_konteynir.visible = !get_tree().paused
	
	if !get_tree().paused:
		gecen_sure += delta
		if gecen_sure >= degisim_suresi:
			gecen_sure = 0.0
			yeni_bilgi_goster()

func yeni_bilgi_goster():
	if bilgi_label == null: return
	bilgi_label.text = bilgiler[mevcut_indeks]
	bilgi_label.visible_characters = -1
	mevcut_indeks = (mevcut_indeks + 1) % bilgiler.size()
	
	if panel_konteynir != null:
		panel_konteynir.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(panel_konteynir, "modulate:a", 1.0, 1.0)
