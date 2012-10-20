# -.- encoding: UTF-8
import re
import urllib2
import pymongo

def striphtml(data):
    p = re.compile(r'<.*?>')
    return p.sub('', data)

def getHTML(url):
    return urllib2.urlopen(url).read()

def getUrlWithQueryAndPage(query, pageNum):
    return "http://www.findprice.com.tw/datalist.aspx?s=g&gn=12864&i=%d&q=%s&o=0""" % (pageNum, query)


ITEM_PATTENR = "<tr >\s*<td align='center' valign='middle' width='70px'>.*?</td></tr>"
ITEM_DETAIL_PATTERN = """<td align='center' valign='middle' width='70px'>\s*"""\
    """<a href='(.*?)'.*? src='(.*?)'.*?<font style='color:#ff0033;font-family:verdana;font-size:11pt;'>"""\
    """<b>(.*?)</b></font></td>.*target='_blank' class='ga'>(.*?)</a>.*"""\
    """</div>\s*(?:<font style='color:#009900'>)?([^>]*?)(?:&nbsp;-&nbsp;</font>)?"""\
    """<a href='datalist.aspx.*>(.*)</a>.*"""\
    """<font size='2' color='#009900'>&nbsp;-&nbsp;(\S*)\s*&nbsp;-&nbsp;"""

def getItemsFromPage(page):
    items_html = re.findall(ITEM_PATTENR,page, re.S)
    items = [] ;
    for item_html in items_html:
        item_data = list(re.findall(ITEM_DETAIL_PATTERN, item_html, re.S)[0])
        item_data[3] = striphtml(item_data[3])
        if item_data[4] == '' :
            item_data[4], item_data[5] = item_data[5], item_data[4]
        item = {
            "url":item_data[0],
            "image":item_data[1],
            "price":int(item_data[2]),
            "name":item_data[3],
            "merchant":item_data[4],
            "lastCheckDate":item_data[6],
            "tag": [],
            }
        if item_data[5] != '':
            item["tag"].append(item_data[5])
        items.append(item)

    return items

connection=pymongo.Connection('localhost',27017)
yhdDB = connection.yhd
itemsCollection = yhdDB.items
def insertItemIntoDB(item):
     itemsCollection.insert(item)
import time
QUERIES="Challenger 6510 紅燒牛肉包麵 關山米 清肌晶角質清淨調理露 厚燒海苔 WP-100 米糕 三代全方位健美機 Calibre es-ga20-w 阿波羅巧克力 波西傑克森 感應式水龍頭 Tactel sdh-148er i3-2100 vx-9021 費雪牌 循環乳 TVC-1015 桌球發球機 維它命E 沙包座 防寒背心 PRO-D 真珠洗髮乳 美樂雙邊 扇子 DBXR463E P5 羅馬鞋 56220 envy4-1018tx 黑木耳露 AT0360-50E p2015d 30ml 維力中華肉燥麵 VFD823-50P BRIDGEPORT 天地合補含鐵 雅典 wmf 洗衣機排水管 苦海女神龍 Kirei 德一 小小酥 Mestemacher mx4 收衣 便利電 群光公司貨 Z981 909 HD-430 記念 華佗雞精 A53SV 小鋼炮吸塵器 天地合補 農心辛拉麵 16kg 509B 金墩 ANKER 養生綜合堅果 精緻單槍沐浴龍頭 強效 G600 婦友 wepon c6-01 435 DA50 我愛你 電器 雙分子玻尿酸 烹大師鰹魚風味調味料 橫濱 派盤 正福堂香港桃酥 KU 藍水晶項鍊 運動休閒包 42LM6200 8mm 終結者 t5 NZXT 貝思 MH-9003 多段式輕巧型 F505 vincent KBH-R22 ELM 機車防塵套 CARSCAM KX-TG6412 單晶片 情不自禁 麗仕白皙煥采沐浴乳 Costa 消光黑 i9250 統一冬蟲夏草雞精 泡沫染髮液 NS-MVF18T 統一滿漢 北海道紅豆雪糕 netVideo 儲物櫃 rc-301 冬蟲夏草烏骨雞 A510E 乾濕兩用超細纖維拖把 珍珠玉米醬 台塑雙氧漂白液 芳第 亞歷山大 U47VC-031A3210M pump kings keepcup 氣化爐 480w gr-rg58tdz 廚具 hf-3522 熱油 protrek 手工醬油 Chevignon 大甲媽祖 高畫質行車紀錄器 CAT 健康一定 人造石 日式超真空保溫瓶 相機記憶卡 雪感肌集中美白晚安凍膜 soeasy rapid F32 黑胡椒牛柳 清潔片 愛美神 淨呼吸高效級靜電空氣濾網 鬱金香 kj-lb18g 強力除臭除菌劑 SEIKO GR-1102 嘉禾 戲水池 感測器 原支圓片高麗蔘 15pin via HE-EP211 E320VL-TW-M inkcolor Skullcrushers 冷凍烏龍麵 鑽白光美肌精華 bruno oc18535 850ML VA1938wa SC-218 S240 玫瑰沐浴乳 70-300 DB-60 TRAVELE 微香 HQ902 TF-6890 griin 西裝褲 旁氏雙重嫩白精華乳 山葵薯條 倒立機 起泡網 SM-819 router FE-001 神奇 Fancy STB CU-G56C2 眼霜 APE BL-5F A3N 3.0V rt-n12 CZ-903 手機 廚具 婦幼 休閒/生活 美妝 精品 寵物 遊戲 相機 眼鏡 手錶 視聽 寢具 服飾".split()
BRANDS ="""
@didi   ACER    ASUS    BenQ    BENTEN
BlackBerry  DOPOD   ELIYA   Fujitsu G_PLUS
GIGABYTE    G-Star  HTC HYUNDAI iPhone
i-tech  LG  Mio Motorola    Nokia
OKWAP   Panasonic   Philips PHS SAMPO
BRANDSSharp   Siemens Sony Ericsson   TATUNG
Toshiba UTEC    VERTU   xcute   三星
中華電信    台灣大哥大  多普達  西門子  宏碁
技嘉    明碁    東芝    飛利浦  神達
國際牌  華碩    黑莓機  愛其華  遠傳
摩托羅拉 樂金   諾基亞  聲寶

3COM    ABOCOM  ACER    A-DATA  AG Neovo
AltCtrl ALTINA  AMD Aopen   Apacer
APPLE   ASRock  ASUS    ATEN    ATi Radeon
AVEXIR  AXIMCom BandLuxe    BELKIN  Benevo
BENQ    Billionton  BUFFALO CANON   CANSONIC
Cellink CERIO   Corega  CTX Decaview
DELL    DIGILION    D-LINK  DOD DOPOD
Dr.eye  ECS Eizo    Elecom  ELSA
EPSON   ETEN    FUJITSU Funtwist    GALAXY
Garmin  Genuine Gigabyte    Gonav   HANNS.G
HiTi    HP  IBM I-INC   Imation
INTEL   IOGEAR  IOMEGA  iPad    j-power
JS  Kingston    KJS KOHJINSHA   Konica Minolta
Kyocera Leadtek LEMEL   Lenovo  Lexmark
LOBOS   Logitech    LSI Maxim   MCIC
Microsoft   MICROTEK    Mio MITAC   MSI
NEC Norton  nVIDIA  OCZ Oki
Olympus ORITE   OZAKI   PalmOne Panasonic
PAPAGO  PC-cillin   PCI Philips PLANEX
PQI Ridata  SAMPO   Samsung SanDisk
Seagate Shuttle Silicon Power   SMC SONY
SUMDEX  Symantec    Targus  Team    Thinkpad
TomTom  TOPRAM  Toshiba TP-Link Transcend
Trend Micro Twinhead    UMAX    unigen  uPink
uptech  Verbatim    Verico  V-Gear  Viewsonic
ViPowER VOSONIC Wacom   WD  Xerox
XOOM    ZO TECH ZOT zynet   ZYXEL
十銓    三星    久森    工人舍  中強
友旺    友訊    友嘉    巴比祿  方吐司
可瑞加  正達    全友    全錄    合勤
多普達  宇帷    宇瞻    艾爾莎  宏正
宏碁    希捷    快譯通  技嘉    邑通
阪京    京瓷    佳能    奇美    奈力特
明碁    東芝    杰強    金士頓  勁永
威剛    威碩    建碁    飛利浦  倚天
倫飛    恩益禧  浩鑫    神達    索尼
國際牌  捷元    創見    富士通  惠普
智鼎    華碩    華擎    微星    微軟
愛普生  新力    零壹    精英    廣穎電通
影馳    磬成    諾頓    錸德    優派
戴爾    聲寶    聯強    聯想    賽門鐵克
趨勢科技    瀚宇    羅技    麗台    蘋果
譯典通
BENQ    CANON   CASIO   DXG FUJIFILM
Kamera  KODAK   KONICA MINOLTA  LEICA   LOMO
MEGXON  Minox   NIKON   OLYMPUS PANASONIC
PENTAX  Praktica    Premier RICOH   Rollei
SAMSUNG SANSON  SANYO   SIGMA   SONY
TAMRON  TOKINA  Toshiba YASHICA Zeiss
卡西歐  佳美能  佳能    明碁    柯達
徠卡    理光    奧林巴斯    騰龍
3M  AGAit   ASKO    BOSCH   BRANDT
BRAUN   Coway   Cuisinart   DAIKIN  DAINICHI
DeLonghi    De'Longhi   Dirt Devil  DURACELL    Dyson
Electrolux  GAGGIA  GE  HANNspree   HELLER
HITACHI Honeywell   iRobot  Janome  Joyoung
KENMORE KOLIN   kozawa  LG  Maytag
Miele   MITSUBISHI  OMRON   OSIM    OSRAM
Panasonic   PHILIPS PRINCESS    Raycop  Saeco
SAMPO   SAMSUNG SANYO   SHARP   SINGER
Stadler Form    Supa Fine   Synco   TANITA  TATUNG
TECO    TES Tiamo   TIGER   TOSHIBA
TOYOTOMI    TWINBIRD    vitamax VIZIO   VORNADO
WestingHouse    Whirlpool   XPAL Power  ZOJIRUSHI   九陽
三星    三洋    三菱    上豪    大同
大金    大家源  小澤    元山    日立
比特數位    北方    白朗    禾聯    伊萊克斯
收藏家  百靈    西屋    車樂美  防潮家
奇異    尚朋堂  易管家  東元    東芝
東龍    松下    虎牌    金頂    勁量
美泰克  迪朗奇  飛利浦  夏普    泰仕
國際牌  荷蘭公主    勝家    博世    惠而浦
晶工    象印    賀眾牌  貴夫人  新格
瑞軒    雷剋蹣  嘉儀    歌林    德國百靈
樂金    歐司朗  歐姆龍  勳風    聲寶
賽寧    鍋寶    瀚斯寶麗
ABOSS   ACER    AIWA    AOC BenQ
BePro   CARY    CHIMEI  COWON iAudio    Creative
DENON   DENPA   Divoom  ESONIC  EVOUNI
Gibson  HANNspree   HERAN   IGO Audio   iPod
JS  JVC KOKA    LG  LITEON
Logitech    Macally Monster Monster Beats   Moshi
NEC NHJ OPTOMA  PANASONIC   PHILIPS
PIONEER Polyvision  PROTON  SAFA    SAMPO
SAMSUNG SANYO   SHARP   SONY    TANNOY
TATUNG  TECO    TiVo    TOSHIBA Viewsonic
VITO    YAMAHA  三星    三洋    大同
山葉    日本鐵三角  可佳    禾聯    先鋒
宏碁    奇美    明碁    東元    東芝
美華    飛利浦  夏普    國際牌  啟航
傑偉世  創新未來    普騰    奧圖碼  愛華
愛歐迪  新力    優派    聲寶    點將家
瀚斯寶麗    羅技    魔聲
Nintendo    SONY PS2主機    SONY PS2週邊    SONY PS2遊戲    SONY PSP 週邊
SONY PSP主機    SONY PSP遊戲    XBOX 主機   XBOX 週邊   XBOX 遊戲
XBOX360 主機    XBOX360 週邊    XBOX360 遊戲    任天堂  任天堂NDS
任天堂Wii 主機  任天堂Wii 遊戲
a.testoni   Adidas  agnes b AIGNER  Alviero Martini
Anna Sui    Balenciaga  BALLY   Barbie  Benetton
borsalini   BOSS    BOTTEGA VENETA  BURBERRY    Bvlgari
BYBLOS  Calvin Klein    CAMPER  CELINE  CERRUTI
CHANEL  CHARRIOL    Chloe   Christian Dior  CK
Clio blue Coach DAKS    Dior    DKNY
DUNHILL DYRBERG/KERN    Elegance    ELLE    EMPORIO ARMANI
ESPRIT  FENDI   Ferragamo   Ferrari FERRE
FILA    Fiorucci    FOCUS   FOSSIL  FURLA
Georg Jensen    Gianfranco FERRE    GIVENCHY    GUCCI   Guess
Hush Puppies    Juicy Couture   Jungle Exploration  KENZO   LANCASTER
LANVIN  LATTE   LeSportsac  Loewe   LONGCHAMP
Louis Vuitton   LV  Marc Jacobs MaxMara MCQUEEN
miu miu MoMS    Montblanc   Morgan  New Balance
NINA RICCI  Nine West   ORIS    Patrick Cox Paul Smith
PLAYBOY PORTER  Prada   PUMA    Ralph Lauren
Roberta Di Camerino Royal Damon S.T.Dupont  Salvatore Ferragamo SISLEY
Swarovski   The Bridge  Tiffany TOD’S   TOD'S
Trussardi   Valentino   Versace Vivienne Westwood   YSL
Yume    凡賽斯  巴黎世家    吉田    安娜蘇
法拉利  芭比    芬迪    保時捷  施華洛世奇
紀梵希  迪奧    香奈兒  夏利豪  班尼頓
都彭    富可仕  登喜路  愛迪達  萬寶龍
聖羅蘭  路易 威登   銀鎮    寶格麗
~H2O+   ADERMA  A-DERMA Aesop   AGATE
Agatha  A'KIN   AKISHIMA    ALBION  ALLIE
ALOINS  Always Black    ANESSA  Ankh    Anna Sui
ANRIEA  APIVITA AQUALABEL   Aramis  Arden
ARTDECO ARWIN   ASIENCE aska    AVALON
Avalon Organics AVEDA   Avene   AVON    AYURA
AZORIA  BabyFoot    Badger  Bath & Body Works   baviphat
Beautician's Secret Beauty Talk BENEFIT BIBO    Bio Plasis
Bio-essence Biopeutic   Biore   Biotherm    Bison
BLANC DE CHINE  BLOSSOM BOBBI BROWN BOLINAS BONANZA
BORGHESE    BOURJOIS    BSL Burt's Bees Canmake
Canus   Cargo   CARITA  Carmex  CARTIDEA
CathyCat    Caudalie    CDNE    CELLEX-C    cellina
Centella    Cetaphil    CEZANNE CHANEL  CHANTECAILLE
CHIC CHOC   CHICODE Christian Dior  Cinci Claire    CINEORA
CLARINS cle de peau BEAUTE  CLINIQUE    COLLISTAR   COSME DECORTE
COSMED  COSMO   CosTrend    COTA    COVERMARK
CRABTREE & EVELYN   C-SKIN  CYBER COLORS    DAINTY  DARIYA
Darphin David Beckham   DEARY   DePas   Derma Formula
DERMAGOR    dermalogica DHC DIOR    DKNY
DOVE    dr.brandt   Dr.Bronner’s    Dr.Ci:Labo  Dr.Hauschka
Dr.HUANG    Dr.Sara Dr.Satin    Dr.Wu   Dr`s Formula
eggshell    Elizabeth Arden Ellgy   emu Endocare
ENPRANI ERH Essential   Estee Lauder    ettusais
Etude   EVE FANCL   fasio   FGF-1
Fiberwig    fonperi FOR BELOVED ONE FORTE   GALATEA
Galenic GARNIER GATSBY  GINLIGHT    Givenchy
GLYSOMED    good skin   Guerlain    HABA    HADA RiKi
HANIX   HAPPY BATH DAY  HBA HELAN   heme
herbacin    HerbTea Hermes  ICE RIVER   IKOVE
IMEDEEN INDIA EATHE INDIA ESTHE INNU    INTEGRATE
IPSA    iPure   ISSEY MIYAKE    IVORY   JAQUA
JASON   Jean Paul Gaultier  Jecy’s  Jennifer Lopez  JILL STUART
Jumelle JURLIQUE    K’erastase  Kamill  Kanebo
KATE    kate moss   kawaii TOKYO    KENZO   Kerastase
K'erastase  KIEHL’S KilaDoll    Kinetin kirei-me
Kiss Me KLORANE Koofs   KOSE    KOZI
K-Palette   KRYOLAN Kylie Minogue   L`EGERE L`OREAL PARIS
L’AMOUR L’ERBOLARIO L’OREAL LA DEFONSE La mer
La Prairie  LA ROCHE-POASY  La Roche-Posay  Labo    LaboLabo
Lactacyd    LANCASTER   LANCOME LANEIGE LANVIN
Lassiet Laura Mercier   Lavshuca    LEADERS LEGERE
L'EGERE L'ERBOLARIO LIERAC  Liese   Lifecella
L'Occitane  LOREAL  L'OREAL LOVE&PEACE  LUNASOL
LUSH    LUX M.A.C   MA CHERIE   MADINA
Majiami MAJOLICA MAJORCA    MAKE UP FOR EVER    Mane’n Tail MAN-Q
MAQuillAGE  Mario Badescu   Mary Quant  MaxFactor   MAYBELLINE
MENTHOLATUM Merle Norman    MICHAEL KORS    Mignon MaiMai   MIKIMOTO
miss SHARK  mod’s hair  MOMUS   MuGu    Muses
NARIS   NARIS UP    NARS    NATIO   Natural kiss
Nature’s Gate   Nature's Gate   Neogence    NeoStrata   Neutrogena
NIGARI  NIVEA   NOIR    NOIR    O2Factory
O2Factory   OGUMA   OLAY    OMI OMI
OraLabs Organic Formulations    Organics    ORIGENERE   Origins
ORIKS   ORIKS   Palgantong  PALMER’S    Pandansari
Pandansari  Pantene Passion G   PATYKA  PAUL & JOE
PAUL MITCHELL   PAUL NIEHANS    PAYOT   PDC Perfect Potion
Philosophy  pHisoDerm   Physicians Formula  PHYTO   plus+JUST@100
POLA    Polynia POND’S  POND'S  Pregaine
Prescriptives   PRIVACY puchure-s   PUPA    Purederm
Red Earth   Refiend RENE FURTERER   revlis  REVLON
REVUE   Rexona  RMK ROJUKISS    Rosebud
Saint-Gervais   SakaguraMusume  SANA    Sanoflore   Sarah Jessica Parker
SaraSara    SASSOON SAUGELLA    Savex   Scholl
Sean John   Seba    Sensatia    Sensimin    SeSDERMA
SEXY GIRL   SexyLook    SHILLS  SHINNING WAY    SHISEIDO
shu uemura  Simply  sisley  SKII    SK-II
SkinMilk    smashbox    SMITH’S Rosebud smith's rosebud SMITH'S ROSEBUD SALVE
SMOOTH-365  SOFEI   SOFINA  Sofnon  SOLONE
Sonia Rykiel    Sony CP SPARITUAL   spunsugar   Sranrom
St. Clare   stila   SUKI    Summers eve SVR
Swabplus    Taiwan Yes  TALIKA  TESCOM  The Body Shop
The tsaio   TIFFA   TIGI    TISS    Tommy
Toruppa TRI-AKTILINE    TRINITYLINE tsaio   TSUBAKI
Tweezerman  Twenty-five U CARE  UNO UNT
URBAN DECAY URIAGE  utena   UV WHITE    Vaseline
VICHY   VITAL SPA   VITASKIN    Wakilala    Wee’p
wee'p   WELEDA  WellnuX Wink up YANAGIYA
YIBI    YSL yuskin  三宅一生    上山採藥
凡士林  小白鯊  丹堤    天然小幫士  天然之扉
日本柳屋    水平衡  水美媒  卡尼爾  卡詩
可伶可俐    台塑生醫    台鹽綠迷雅  立朵舒  伊美婷
伊蔻菲  冰河    多芬    安娜蘇  安蔻
曲線女王    有機宣言    朵瑪    米米加  肌膚之鑰
艾杜紗  艾芙美  艾美柔  艾倫比亞    艾莎古薩
艾蜜塔  艾黎亞  克蘭詩  妙巴黎  希思黎
快樂沐浴天  我的美麗日記    杜克    杜克左旋C   沙宣
貝吉獾  貝佳斯  京都同仁堂  依必朗  佳麗寶
佰松    奇士美  奇拉朵  妮傲絲翠    妮維雅
帕瑪氏  肯拿士  芳珂    芭比波朗    花王
近江兄弟    阿葵亞  品木宣言    契爾氏  思波綺
施巴    施普樂  柏姿    柏黎仕  柳屋
珍妮佛羅培茲    紀梵希  美人心機    美人語  美肌醫生
美諦高絲    美禪    美體小舖    耐斯澎澎    迪奧
飛柔    香奈兒  香緹卡  倩碧    娜莉絲
娜麗絲  旁氏    桑麗卡  泰奧菲  浪凡
海洋拉娜    海倫仙度絲  茵芙莎  酒藏娘  馬用
高堤耶  高絲    曼秀雷敦    康是美  御木本
悠斯晶  清肌晶  爽健    理膚寶水    莎啦莎啦
莎薇    莉婕    雪肌精  雪芙蘭  雪瓷
婕若琳  凱特摩絲    凱茵庭  凱婷    媚比琳
富勒烯  植村秀  棉花糖  無齡肌密    舒妃
舒特膚  舒逸敏  舒摩兒  萊法耶  萊思特
萊雅    菲希歐  菲蘇德美    逸萱秀  雅芳
雅洛茵斯    雅詩蘭黛    雅頓    雅漾    雅聞
黃禎憲  黑龍堂  塔麗卡  奧舒亞  愛姬
愛馬仕  愛潔兒  瑞士瑞療    聖克萊爾    聖泉薇
聖莎緹亞    聖羅蘭  落建    萱薇    葛拉蒂
葆療美  詩芙雅  詩芙儂  詩蘭諾  資生堂
歌劇魅影    瑪丁娜  瑪奇亞米    瑪宣妮  瑪莉官
瑪麗歐‧倍思酷   瑰珀翠  碧兒泉  碧蕾絲  綠迷雅
維妮舒  蜜妮    蜜絲佛陀    輕．男人    劇場魔匠
嬌生    嬌蘭    廣源良  德國世家    摩爾羅曼
歐博士  歐舒丹  歐蕾    歐麗淨  潤肌精
潘朵莎芮    潘婷    膚蕊    蓮芳    髮朵
黎得芳  黎瑞    蔻迪亞  蔻莉絲塔    蔻蘿蘭
蕊娜    霓淨思  優方    優白    優姿
優麗雅  蕾莉歐  薇姿    薇莉達  賽吉兒
賽斯黛瑪    黛珂    寵愛之名    麗仕    寶貝腳
寶藝    蘇菲娜  儷德詩  蘭吉兒  蘭芝
蘭寇    蘭蔻    蘭韻    露得清  露華濃
戀愛魔鏡
a.b.art """
BRANDS="""Adidas  AIGNER REVENNA  ALBA    Alexandre Christie
ARBUTUS ARMANI  Audemars Piguet BALL    Betsey Johnson
BijouMontre BREITLING   bruno banani    BULOVA  BURBERRY
Calvin Klein    CARTIER Casio   CHANEL  CHARRIOL
CHOPARD Christian Dior  CITIZEN Cloie   CONCORD
CONSTANT    CORUM   crocodile   CYMA    DIESEL
DILONGER    DKNY    DOXA    Dunhill ELLE
EMPORIO ARMANI  ENICAR  epos    ESPRIT  EUROSTAR
FENDI   Folli Follie    FOSSIL  FRANCK MULLER   Gc Diver Chic
GUCCI   GUESS   Hamilton    Hanna   Heuer
ICE Watch   INVICTA IWC JAGA    JEANRICHARD
Jebely  JLO JOJO    Kenneth Cole    KOOKAI
LICORNE Longines    Louis Erard Luminox Lunabianca
Marc Ecko   Maurice Lacroix MAX&CO  MIDO    MIDO Multifort
Mondaine    MOSCHINO    NAFNAF  NOMOS   o.d.m.
Oakley  OGIVAL  OMEGA   OP  ORIENT
ORIS    Panerai PATEK PHILIPPE  PIAGET  PIMP LED
PUMA    RADO    RAYMOND WEIL    raymond-weil    REVUE THOMMEN
RN  ROAMER  ROLEX   round well  SEIKO
SIGMA   SINN    Surich  Swarovski   Swatch
TAG Heuer   TED BAKER   TIMEX   TISSOT  TITONI
TITUS   Traser  TroFish(TF) TUDOR   Vacheron Constantin
VACHERON CONSTANTN  viceroy Victorinox  VOGUE   Wenger
ZEPPELIN    力抗錶  天梭    卡地亞  卡西歐
司馬錶  江詩丹頓    百年靈  百達翡麗    艾美
君皇錶  沛納海  尚維沙  東方錶  波爾錶
帝舵    施華洛世奇  星辰    珍妮佛羅佩茲    美度
迪奧    夏利豪  浪琴    浪琴    康斯登
梭曼    梅花錶  勞力士  勞斯丹頓    登喜路
雅柏    奧林比亞    愛其華  愛彼特  愛迪達
愛寶時  瑞士國鐵    瑞士維氏    萬國錶  漢米爾頓
精工    豪雅    歐米茄  蕭邦    蕾蒙威
寶路華  蘇黎世  鐵達時
ADHOC   agnes b.    ALAIN DELON ALVIERO MARTINI ANNA SUI
ARMANI  BOLLE   BOSS    BURBERRY    ByWP
CELINE  CHANEL  Chloe   Christian Dior  D&G
DERAPAGE    DIESEL  DKNY    DOLCE&GABBANA   DZ
EASTON  ESCADA  Ferrari GIVENCHY    GROOVY FACE
GUCCI   Hammer  HIPONI  KARL LAGERFELD  levi's
LOEWE   Love Nation MAJI MAJI   MARC JACOBS Masaki Matsushima
MIU MIU MIZUNO  MONT BLANC  MOSCHINO    OAKLEY
OLIVER PEOPLES  OMMAETUM    PAUL FRANK  Playboy pls.pls.
POLICE  POLO RALPH LAUREN   PRADA   Ray Ban RayBan
Ray-Ban ROMEO GIGLI Salvatore Ferragamo silhouette  SPIVVY
TED BAKER   tempus  Trussardi   VERSACE Vivienne Westwood
YSL zerorh  Z-POLS  凡塞斯  大嘴猴
安娜蘇  亞曼尼  亞蘭德倫    法拉利  紀梵希
美津濃  迪奧    香奈兒  將太郎  聖羅蘭
詩樂    雷朋
ALEX    AVENT   BABY ACE    Baby City   Baby Zone
BabyBabe    Baby-House  BENNY   Bfree   Capella
Carrot  CD BABY Combi   Coochi  Dr. Brown’s
Ecostore    eightex ELLE POUPON Fisher-Price    Gigo
Glico   GOO.N   Gymboree    Kids II K's Kids
KU.KU.  Lamaze  LeapFrog    LEGO    Libresse
Little Tikes    MamaWay medela  Merries mister BABY
moomin  Mother's Love   MUNCHKIN    Nac Nac Naforye
NISSEN  NKOK    okiedog OrganicLove Pampers
papas   People  PIGEON  Piyo    PiyoPiyo
PUKU    Q-BBY DOG   s26 Sankyo  Sassy
Seba    Sebamed Smoby   SYNCON  TINY LOVE
TOMY    Toyroyal    wallaboo    久達尼  小玩童
小凱撒  小獅王  六甲村  日本大王    日雅
丘比    巧虎    巧連智  向綠    好自在
安體潔  艾比熊  妙兒舒  貝恩    貝親
貝麗    和光堂  固力果  奇哥    拉孚兒
拉梅茲  東京西川    欣康    思詩樂  施巴
班恩傑尼    培樂多  康貝    智高    費雪牌
黃色小鴨    媽媽餵  愛兒房  滿意寶寶    嬌生
嬌爽    樂高    樂雅    靠得住  優健
幫寶適  蕾妮亞  黛安芬  嚕嚕米  藍色企鵝
麗嬰房  蘇菲
A Bathing Ape   A&F Abercrombie Abercrombie&Fitch   acupuncture
AIR SPACE   aPure   Armani Jeans    Arnold Palmer   AS
asics   ATUNAS  BAPE    BCBG    BESO
BIG TRAIN   Blue Cult   Blue Way    bluehaven   Bobson
CareMilieu  cecile  Chevignon   Cogozoco    CONVERSE
Crocodile   crocs   D&G DADA    Diesel
DSQUARED2   Earnest Sewn    ecco    Ed Hardy    EDWIN
ENERGIE Evisu   FORSTYLE    Frankie B   GAP
GILDAN  Giordano    G-Star  HANG TEN    Helmut Lang
IRUKA   izzue   Kappa   K-SWISS L.A GEAR
LACOSTE lativ   Le Coq Sportif  Lee Levi's
LOTTO   Lowrys Farm marlboro classics   Miss Sixty  Miss sofi
moussy  nani    NAUTICA Ophelie OZOC
Pierre Cardin   POLO    Pringle REEF    Roberta
Roots   saucony Sonia   Stussy  TATTOO
Timberland  Tommy Hilfiger  True Religion   UGG UNIQLO
Valentino Coupeau   VANS    VISOGE  windland    Wrangler
ZARA    中國強  皮爾卡登    佐丹奴  克黴樂
亞瑟士  思薇爾  曼黛瑪璉    莎薇    華歌爾
瑪登瑪朵    歐都納  諾貝達
3M  Annabelle   ANSON   Body's  CUPID
Cutie Berry D`urban Dan Nice    Dohia   Dream Home
Duoluxe Ever Soft   EverSoft    EzTek   Fancy Belle
FASON   GOLDEN TIME GUESSERI    HongYew HOYA
Jane&Sally  JUNYA   Kay Ungar   La Belle    LA MAISON
La mode LADY AMERICANA  Lily Malane Lily Royal  LITA
LooCa   Louis Casa  MARTONEER   Maslow  McQueen‧麥皇后
Mi Casa Microban    Miu's   Montagut    Moon-Turns
Novaya  OGURI   Pathfinder  Perdormire  PIERRE BALMAIN
PURPLES Reverie RODERLY Royal Mihazu    Saint Rose
Sanitized   SCHROERS    Sha Shyuan  Simmons sleepmaster
TEMPUR  Tonia Nicole    YVONNE  Zean's  二丈莊
丹普    幻知曲  以旺    北之特  皮爾帕門
伊登名床    老K牌   西崎    亞曼達  東妮
波多米  法國SONIA   法頌    金時代  契斯特
思尼安  派菲德  席夢思  桃樂絲  御之竹
莎萱    莉莉瑪蓮    都爾本  凱曼朵  凱蕾絲帝
斯林百蘭    絲麗翠  萊儷絲  夢工場  夢公爵
夢特嬌  夢樂    睡眠大師    輕鬆睡  德泰
德國GLORY   歐帝寶  黎安思  諾曼亞  霏彤小可
濱川佐櫻    穗寶康  韓國 IN HOUSE   鴻宇    鴻象
麗塔
ACANA   Ami Dog ANF ARM & HAMMER    AZOO
CANIDAE Cat's Best  Cesar   Chicken Soup    DoggyMan
Dogsin  Eukanuba    fish4dogs   GloryPet    GREENBONE
IRIS    LUILUI  Mobby   Natural Balance Nutrience
Nutro   OPTIMA  Organix ORIJEN  OVEN-BAKED
PETIO   Swabplus    VF  Vitakraft   五角綠
卡比飼料    多益樂  西莎    希爾思  沛貝兒
沛蒂露  法國皇家    施普樂  美士    耐吉斯
海洋之星    強品    莫比    凱優    創鮮
愛肯拿  愛恩富  聖萊西  瑪丁    福壽
歐奇斯  優卡    優格    魏大夫  關愛博士
寶多福  寶貝狗  鐵鎚
AMARDA  ARISTON Arzberg bodum   BRITA
Chilewich   Ekobo   GLOBAL  HCG IKEA
Kai LEONARDO    LUMINARC    PADERNO Revol
sacnpan Safepan SAKURA  SIGG    SUGAHARA
SUPOR   Thermos Tiamo   TWINTEN WINDSOR
Xtrema  Xylan   三光牌  三箭牌  牛頭牌
旬SHUN  貝印    和成    林內    法國特福
阿里斯頓    思康    柳宗理  康寧    莊頭北
喜特麗  掌廚    斑馬牌  無煙炊具    義廚寶
鼎上坩堝    樂美雅  膳魔師  鍋寶    蘇泊爾
櫻花    鑫司
American Tourister  CEJ Chaco   Durex   EMINENT
FitFlop Giant   Hideo   HIDEO WAKAMATSU ibanez
KHS KYMCO   Merida  MIZUNO  New Balance
NIKE    RIMOWA  Roncato Samsonite   Snuggle
SYM TAHHSIN THE89   timberland  TIMBUK2
tokuyo  TRAVEL FOX  Trunki  Vangather   YAMAHA
Zakka   三陽    山葉    五月花  光陽
克潮靈  吸易潔  妙管家  杜蕾斯  花仙子
美利達  美津濃  捷安特  梵佳特  野狼
舒潔    雅仕    督洋    達新    熊寶貝
橘子工坊
Abbott  Amo bioenergy   Condix balance life GTC
Kellogg's   KGCHECK McCormick   Olitalia    O'natural
OREO    QUAKER  RITZ    SSY 卜蜂
三好米  丸莊    大成    大統    小肥羊
天仁    日正    牛頭牌  可口可樂    台鳳
白蘭氏  光泉    百吉    百事可樂    百家珍
你滋美得    李時珍  李錦記  豆油伯  乖乖
亞培    京都念慈菴  味丹    味王    味全
味好美  旺旺    明治    金台展  金車
金蘭    阿默    南僑    紅布朗  食家諾姆拉
家樂氏  桂格    泰山    真好家  馬玉山
康迪    康師傅  康寶    得意的一天  掬水軒
盛香珍  祥欣裕  統一    喜年來  富味鄉
森永    湯廚    黑松    黑師傅  塔吉特
奧利塔  奧利奧  愛之味  新東陽  萬大酵素
萬家香  義美    葡萄王  福懋    綠巨人
維力    維大力  德昌    歐納丘  養樂多
憶霖    聯華    麗滋 """.split()



for query in BRANDS:
    pageNum = 1
    while True:
        print query, pageNum
        time.sleep(0.5)
        page = getHTML(getUrlWithQueryAndPage(query,pageNum))
        items = getItemsFromPage(page)
        for item in items:
            insertItemIntoDB(item)
            print item
        if len(items) == 0:
            break
        pageNum += 1

