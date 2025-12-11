## 1.将Firebase下载的GoogleService-Info.plist文件放到项目目录

## 2. 需要在 Info.plist 文件中添加多语言的 `NSUserTrackingUsageDescription` 描述（iOS 14+ 必配，用于说明用户跟踪权限用途，适配不同地区用户）：
```xml
<!-- Info.plist 多语言 NSUserTrackingUsageDescription 配置 -->
<!-- 英语 -->
"NSUserTrackingUsageDescription" = "We want to understand which ad led to your download, so we can provide you with more relevant content. You can choose whether to allow this.";

<!-- 葡萄牙语（巴西） -->
"NSUserTrackingUsageDescription" = "Queremos entender qual anúncio levou ao seu download, para que possamos oferecer conteúdo mais relevante para você. Você pode escolher se permite ou não.";

<!-- 西班牙语（墨西哥） -->
"NSUserTrackingUsageDescription" = "Queremos saber qué anuncio generó su descarga, para brindarle contenido más relevante. Usted puede elegir si permite esto o no.";

<!-- 日语 -->
"NSUserTrackingUsageDescription" = "どの広告からダウンロードされたかを把握し、より関連性の高いコンテンツを提供するためです。許可するかどうかはお選びいただけます。";

<!-- 越南语 -->
"NSUserTrackingUsageDescription" = "Chúng tôi muốn biết quảng cáo nào dẫn đến việc bạn tải xuống, để cung cấp nội dung phù hợp hơn cho bạn. Bạn có thể chọn cho phép hoặc không.";

<!-- 德语 -->
"NSUserTrackingUsageDescription" = "Wir möchten verstehen, welcher Anzeige Ihre Herunterladung zugrunde liegt, damit wir Ihnen relevanteres Content bieten können. Sie können selbst entscheiden, ob Sie dies erlauben.";

<!-- 土耳其语 -->
"NSUserTrackingUsageDescription" = "Hangi reklamın indirmeyi tetiklediğini anlamak istiyoruz, böylece size daha ilgili içerik sunabiliriz. İzin vermek veya vermemek konusunda seçim yapabilirsiniz.";

<!-- 法语 -->
"NSUserTrackingUsageDescription" = "Nous souhaitons savoir quelle annonce a conduit à votre téléchargement, afin de vous proposer du contenu plus pertinent. Vous pouvez choisir de permettre cela ou non.";

<!-- 泰语 -->
"NSUserTrackingUsageDescription" = "เราต้องการทราบว่าโฆษณาหนึ่งใดที่นำไปสู่การดาวน์โหลดของคุณ เพื่อให้เราสามารถให้เนื้อหาที่เกี่ยวข้องมากขึ้นแก่คุณ คุณสามารถเลือกระบุว่าให้อนุญาตหรือไม่";

<!-- 意大利语 -->
"NSUserTrackingUsageDescription" = "Vogliamo capire quale annuncio ha portato al tuo download, per poterti offrire contenuti più pertinenti. Tu puoi scegliere se permetterlo o meno.";

<!-- 韩语 -->
"NSUserTrackingUsageDescription" = "어떤 광고에서 다운로드가 발생했는지 파악하여 보다 관련성 높은 콘텐츠를 제공하기 위함입니다. 허용할지 여부는 선택하실 수 있습니다.";

<!-- 中文（繁体） -->
"NSUserTrackingUsageDescription" = "我們希望了解哪個廣告帶來了下載，以便為您提供更相關的內容。您可以選擇是否允許。";

<!-- 中文（简体） -->
"NSUserTrackingUsageDescription" = "我们希望了解哪个广告带来了下载，以便为您提供更相关的内容。您可以选择是否允许。";

<!-- 波兰语 -->
"NSUserTrackingUsageDescription" = "Chcemy wiedzieć, który reklamę spowodował twój pobieranie, aby móc Ci zapewnić bardziej odpowiednie treści. Możesz wybrać, czy to zezwolisz.";

<!-- 印尼语 -->
"NSUserTrackingUsageDescription" = "Kami ingin mengetahui iklan mana yang menyebabkan unduhan Anda, sehingga kami dapat memberikan konten yang lebih relevan untuk Anda. Anda dapat memilih apakah akan mengizinkan ini atau tidak.";

<!-- 俄语 -->
"NSUserTrackingUsageDescription" = "Мы хотим понять, какой рекламный ролик привел к вашему скачиванию, чтобы предоставить вам более релевантный контент. Вы можете выбрать, разрешить это или нет.";

<!-- 阿拉伯语 -->
"NSUserTrackingUsageDescription" = "نريد معرفة أي إعلان أدى إلى تنزيلك، حتى نتمكن من تزويدك بالمحتوى الأكثر صلة. يمكنك اختيار السماح أم الرفض.";

<!-- 荷兰语 -->
"NSUserTrackingUsageDescription" = "We willen begrijpen welke advertentie tot uw download heeft geleid, zodat we u relevantere inhoud kunnen bieden. U kunt kiezen of u dit toestaat.";

<!-- 挪威语 -->
"NSUserTrackingUsageDescription" = "Vi ønsker å forstå hvilken annonse som førte til nedlastingen din, slik at vi kan gi deg mer relevant innhold. Du kan velge om du vil tillate dette.";

<!-- 以色列希伯来语 -->
"NSUserTrackingUsageDescription" = "אנו רוצים להבין איזו פרסומת הובילה להורדה שלך, כדי שנוכל לספק לך תוכן רלוונטי יותר. אתה יכול לבחור האם לאשר זאת.";
```

## 3.添加以下值到Info.plist文件
```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4fzdc2evr5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>2fnua5tdw4.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ydx93a7ass.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>p78axxw29g.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v72qych5uu.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ludvb6z3bs.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cp8zw746q7.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3sh42y64q3.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>c6k4g5qg8m.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>s39g8k73mm.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3qy4746246.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>f38h382jlk.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>hs6bdukanm.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>mlmmfzh3r3.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v4nxqhlyqp.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>wzmmz9fp6w.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>su67r6k2v3.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>yclnxrl5pm.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>t38b2kh725.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>7ug5zh24hu.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>gta9lk7p23.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>vutu7akeur.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>y5ghdn5j9k.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v9wttpbfk9.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>n38lu8286q.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>47vhws6wlr.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>kbd757ywx3.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>9t245vhmpl.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>a2p9lx4jpn.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>22mmun2rn5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>44jx6755aq.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>k674qkevps.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4468km3ulz.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>2u9pt9hc89.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>8s468mfl3y.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>klf5c3l5u5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ppxm28t8ap.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>kbmxgpxpgc.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>uw77j35x4d.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>578prtvx9j.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4dzt52r2t5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>tl55sbb4fm.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>c3frkrj4fj.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>e5fvkxwrpn.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>8c4e2ghe7u.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3rd42ekr43.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>97r2b46745.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3qcr597p9d.skadnetwork</string>
    </dict>
</array>
```
