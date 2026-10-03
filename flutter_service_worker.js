'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "7046b764092bbcc116218c040a45ee95",
"index.html": "31890b8b3cadceab21c0d43611a0e052",
"/": "31890b8b3cadceab21c0d43611a0e052",
"main.dart.js_1.part.js": "f03830ed5eb50f94e5b3ed8caf901f85",
"main.dart.js": "edd0c6bbaa1e692d8ff218d4a03effe4",
"version.json": "787c7d311eb67500934c1b061a5e198e",
"assets/assets/data/canon.json": "cced79877edfb4a3d98221423aa5c291",
"assets/assets/data/throughlines.json": "d8619d0d0a4e94a2e4bd6ace9de6c581",
"assets/assets/data/spot.json": "e41d66411211cdef15b79a1b89cf30b8",
"assets/assets/data/menswear.json": "d11c93f00162dbc34bec40b52cc78c8c",
"assets/assets/data/menswear_archetypes.json": "366cd70bd117e87b9115c04bbccbc0cc",
"assets/assets/data/menswear_spot.json": "6db33d771441d23dc556e0b0d54a3526",
"assets/assets/images/deck/manifest.json": "1dc703e2d64518a06f3dfdc1fea7b4db",
"assets/assets/images/deck/arch-1.jpg": "015de481723d6cdebe7d7b726e7f1649",
"assets/assets/images/deck/arch-2.jpg": "9004dbafd1d5f8cbe4dc2629042b9f86",
"assets/assets/images/deck/arch-3.jpg": "369b5e142dd36a71d5cc6687434c950e",
"assets/assets/images/deck/arch-4.jpg": "0c9713c27d0dd4d4e6544def6df818af",
"assets/assets/images/deck/arch-5.jpg": "2f36c438e967b35dba26417d17959e9f",
"assets/assets/images/deck/arch-6.jpg": "630d05c1c57cc303190f14f3eee7a393",
"assets/assets/images/deck/arch-7.jpg": "4f73ae938af2c420bab32d88ad007b35",
"assets/assets/images/deck/arch-8.jpg": "507d7b6d94727084ed624c5a0848294d",
"assets/assets/images/deck/tail-1.jpg": "98cd301472be123d2e60c4b801ccb506",
"assets/assets/images/deck/tail-2.jpg": "8a8559f9ec2386c0219785e6449d4973",
"assets/assets/images/deck/tail-3.jpg": "c84748ec93ecc7df601e6a088444b4bc",
"assets/assets/images/deck/tail-4.jpg": "870da379d0fb5d45662d17b003e2c7bb",
"assets/assets/images/deck/tail-5.jpg": "2c5abe2f4b3906ff3c83faca93608a51",
"assets/assets/images/deck/tail-6.jpg": "735e8dc820872cf185fe7dbd6a0e6585",
"assets/assets/images/deck/tail-7.jpg": "a4ed0f428a8e2bf6855ce8072d8976d2",
"assets/assets/images/deck/tail-8.jpg": "6b403a61c8563bdc0354f762bee6be02",
"assets/assets/images/deck/int-1.jpg": "9664af498bac723a737b424fe99d0841",
"assets/assets/images/deck/int-2.jpg": "f3912b564ed0cfe29e647ab6fbebe57f",
"assets/assets/images/deck/int-3.jpg": "156a614fec5f4dd0f5e6a7f535634bce",
"assets/assets/images/deck/int-4.jpg": "cf74a1b1dabefbb706b1e654e9428f25",
"assets/assets/images/deck/int-5.jpg": "485689283574a9949163880f4df80ac4",
"assets/assets/images/deck/int-6.jpg": "0c2436971e28fab8b052cd20b87851eb",
"assets/assets/images/deck/int-7.jpg": "06c61300f7d2ab787cdff0f8c8976d2b",
"assets/assets/images/deck/int-8.jpg": "4e29f6a9369bbb35d6f2c27249ad2625",
"assets/assets/plates/aline-open.svg": "dfccecd36d8fd00c268d758b3bea6279",
"assets/assets/plates/aline-straight.svg": "d359ee2e2fb8740a20b3413e603ce378",
"assets/assets/plates/aline.svg": "b7b4e592c206d072e7edfe7beff5d199",
"assets/assets/plates/armhole-high.svg": "57b4cf46e47bd9087939af67b3ed5e13",
"assets/assets/plates/armhole-low.svg": "b630e1fa1d23be6a7e592b95a39160a7",
"assets/assets/plates/armhole.svg": "bf4932855df92626b118850a30030954",
"assets/assets/plates/betonbrut.svg": "4a8d55877e4d89a0eef33bac0a605489",
"assets/assets/plates/biophilic-full.svg": "a18455ee00d7c1a928c5663f5cf4f710",
"assets/assets/plates/biophilic-plant.svg": "ca48a1e3c80f2b9773c1a64b5d343cd7",
"assets/assets/plates/biophilic.svg": "52ab703ec66eb04ab0b89fdde29ab753",
"assets/assets/plates/brut-faced.svg": "25782f4efa485954a737e9e75f6d21e0",
"assets/assets/plates/brut-raw.svg": "b8308e7bbc47bd7fa095fbe78b052661",
"assets/assets/plates/collar-notch.svg": "e73d61063c47d238adc1a35e2ada76fd",
"assets/assets/plates/collar-stand.svg": "78264696f08c7211aa9ff41b8449e73d",
"assets/assets/plates/collar.svg": "78f154aacd0b8eda0e4d8a26a3cff90a",
"assets/assets/plates/drape-full.svg": "6cd92c39b9ccf0bb78617765a4db6d67",
"assets/assets/plates/drape-slim.svg": "61bae03206fe2fef273d296868677aff",
"assets/assets/plates/drape.svg": "9e418a2a7b3ad588b5973075858f3e62",
"assets/assets/plates/enfilade-aligned.svg": "9378f536e801321b4420b2dc644ef7f3",
"assets/assets/plates/enfilade-staggered.svg": "64f0516e539e05b083f2c94fb9e017a1",
"assets/assets/plates/enfilade.svg": "cbf538f18a3519396153bd0464ae2233",
"assets/assets/plates/gorge-high.svg": "e071a629d187a970427becdfebdd7652",
"assets/assets/plates/gorge-low.svg": "99609eaac3d3e320a9d95326e17fcfa5",
"assets/assets/plates/gorge.svg": "55e898aefb58d98c09948095b2bde880",
"assets/assets/plates/japandi-blend.svg": "28b5cfaa855b581693a6edc7e21cf029",
"assets/assets/plates/japandi-cold.svg": "aa04508ffc63dcbfb40f416330f288a4",
"assets/assets/plates/japandi.svg": "fe781013004c64207ef5301a2fca3de3",
"assets/assets/plates/ma-full.svg": "605d35b38ec89a0c425cd1161b162bc0",
"assets/assets/plates/patina-new.svg": "2d723b9334198c4c36fa811ad76ae115",
"assets/assets/plates/patina.svg": "1fc7ea8f4d81cabb60596be24b378d55",
"assets/assets/plates/pilotis-grounded.svg": "a249138c9d6e6743143696a94d0f51d0",
"assets/assets/plates/pilotis-lifted.svg": "9b450ffac4c13d2cd6633d5d5a6f2ced",
"assets/assets/plates/pilotis.svg": "9987b5c70f431464488057aca5cf4313",
"assets/assets/plates/sack-shaped.svg": "05a68c1ca0293f6a4872f364b76d658f",
"assets/assets/plates/poche-outline.svg": "4fee635f7e7d81b8a29e1202e1de8713",
"assets/assets/plates/sack-straight.svg": "005daf9c84ab26e9841440f4e9cea6c2",
"assets/assets/plates/sack.svg": "69cebe81317f37279b4797aa4a317730",
"assets/assets/plates/shibui-busy.svg": "40f23f81bd3e02fb80a895f80f1f61e9",
"assets/assets/plates/shibui-quiet.svg": "67c88009f4f4d6bff2917e0d31c94abc",
"assets/assets/plates/shibui.svg": "4e90a2c5a3741f176febe5e0d44980c1",
"assets/assets/plates/shoulder-roped.svg": "04b903888a83875c9480c331d853a751",
"assets/assets/plates/shoulder-soft.svg": "255b72c19d25f49ec77fcf7c0d7f9601",
"assets/assets/plates/shoulder.svg": "b8873661217f493620cb254e02563b8c",
"assets/assets/plates/suppression-none.svg": "60ed52ec44aae6919501847a11734969",
"assets/assets/plates/suppression-strong.svg": "242534ce69b09ccd6f3299f430c0c83b",
"assets/assets/plates/tectonic-expressed.svg": "7e7fd2ad97a00e811550a142ccac1639",
"assets/assets/plates/tectonic-hidden.svg": "8a6302c4a39546782855c4d3333b63ee",
"assets/assets/plates/tectonic.svg": "b121ca41ad28a3d2cc862f74f889d475",
"assets/assets/plates/truth-faked.svg": "a25ad2ead34d1b8bd4f546efc9794c23",
"assets/assets/plates/truth-honest.svg": "7ff9f595dfcac9b877ff5cd9054361a3",
"assets/assets/plates/truth.svg": "1b9aeb1ad150d0ba0ef6a7cb90713fba",
"assets/assets/plates/wabisabi-perfect.svg": "c04db0d2bc4f90c8e013df14aef03db4",
"assets/assets/plates/wabisabi-repaired.svg": "f8f0a1cc831c8d0a379a897af2381c0d",
"assets/assets/plates/wabisabi.svg": "8f4d7545b6c99c614b68912c9482b07f",
"assets/assets/plates/xline.svg": "c3a43e2bbb1b8c62ad87d57c5b96a0f3",
"assets/assets/plates/patina-earned.svg": "b3d44d0cd4fd504884bf5cfc036d54f2",
"assets/assets/plates/poche.svg": "5126cf6e53bc8ae6323bf94d1f8df624",
"assets/assets/plates/poche-filled.svg": "10ac231c4d3534491dca289bc29899f7",
"assets/assets/plates/henley.svg": "c91a19cabe8b0f94c69f85428e57ed98",
"assets/assets/plates/oxford-shirt.svg": "e2e5d957ceb5f34245e81a2bc3d7fe4b",
"assets/assets/plates/polo.svg": "a7af96fec45e3c98af80be65880f44ca",
"assets/assets/plates/band-collar.svg": "55378f972b924b9e4e7f4c729c1fdf5e",
"assets/assets/plates/bomber.svg": "8e43cb332725956df3fd876c62bb2b69",
"assets/assets/plates/button-down-collar.svg": "a9c4d03f70dfcee55ecaea8f35bda285",
"assets/assets/plates/camp-collar.svg": "6f0ba3503fa8719bd43895a36d1581f9",
"assets/assets/plates/canvas-plimsoll.svg": "2f1c99522f1acb453161b4e01bfc4319",
"assets/assets/plates/cargo-trouser.svg": "08556ff63f0296f1cc4a49cc719028b5",
"assets/assets/plates/chambray-shirt.svg": "d03dc00a50288335c4b452514edfb419",
"assets/assets/plates/chore-coat.svg": "9037c85db8fb161854385f26c1201218",
"assets/assets/plates/chelsea-boot.svg": "84b08fa4509351a98ad51adc5a375a90",
"assets/assets/plates/chukka-desert-boot.svg": "db79fc25376b15e1807545c7b4101740",
"assets/assets/plates/chunky-dad-sneaker.svg": "a4a7a4cb46f85cc6f7b7f150037cd36c",
"assets/assets/plates/club-collar.svg": "d50db44ff5816b7002e1a642f5a327ae",
"assets/assets/plates/crew-tee.svg": "6ddcfa3e9cb12bf2d1861599fce70e49",
"assets/assets/plates/crewneck-sweatshirt.svg": "464d78fc6e296a98d123aeb2639ec862",
"assets/assets/plates/cropped-length.svg": "7222e5950edb14dde1da0fb637952cf6",
"assets/assets/plates/derby.svg": "a80c2b9152cee0b9b8625855159433ba",
"assets/assets/plates/drawstring-trouser.svg": "ed1d0278364822ced9904d790e9bbd2c",
"assets/assets/plates/field-jacket-m65.svg": "723e0264e761cf3c599d57bd8e4ccc75",
"assets/assets/plates/flannel-shirt.svg": "7c76a840eb62afc52aa21bad917419e3",
"assets/assets/plates/five-pocket-denim.svg": "ef7506a9b5807f192ef3a2a6008ee94a",
"assets/assets/plates/flat-front-chino.svg": "f778712eb6d61c8b873b90c373859e96",
"assets/assets/plates/hoodie.svg": "29c3e4945f40508e0f11b07d8fa5b6e7",
"assets/assets/plates/knit-polo.svg": "df820a94ad85d8b6fa8a1c4ff7b47c92",
"assets/assets/plates/harrington.svg": "dc1256ce86f14f4236095058c0d720fa",
"assets/assets/plates/loafer.svg": "aab36de67fa71f93b8bc72426acbb3b8",
"assets/assets/plates/low-top-sneaker.svg": "fa0b6e020b0fc35e1b19285a0330ffe2",
"assets/assets/plates/monk-strap.svg": "51f530239eb2eff4578f9e9f260f44f4",
"assets/assets/plates/moto-jacket.svg": "aafa94a60ab802a3af86ea6f74c63a4d",
"assets/assets/plates/overshirt-shacket.svg": "45ade8415efcbd46965badafe91a46b4",
"assets/assets/plates/parka.svg": "ce491d0b3d8dd309289faec567513483",
"assets/assets/plates/peacoat.svg": "ba7383167c77669027eab92fa4f589f9",
"assets/assets/plates/pleated-trouser.svg": "2024c3f1eae4b24ec9197f7884c91f19",
"assets/assets/plates/point-collar.svg": "0a5bb1b661fb40a9eea321f5897a1c2a",
"assets/assets/plates/puffer.svg": "5ac9927cfaf47fbd3bb0c086221c8c87",
"assets/assets/plates/quilted-liner.svg": "9fe3442f00768345403692db8e32f521",
"assets/assets/plates/relaxed-fit.svg": "3d971c493dcc7eb59ef446fd07fcbd47",
"assets/assets/plates/rugby-shirt.svg": "1c53f5242ccb074abd7894d490e43cbd",
"assets/assets/plates/selvedge-straight-denim.svg": "73e65ecdd8597efa5bbc9feef4a79d94",
"assets/assets/plates/service-boot.svg": "cf04980861765fa159dfd6891b4b39ac",
"assets/assets/plates/slim-fit.svg": "6f85dcefd4bcbde3f21f626a1330d3a7",
"assets/assets/plates/spread-collar.svg": "03df594771b282e17a9d833076567e48",
"assets/assets/plates/straight-fit.svg": "7d65336f380d555167a0ff8209881ceb",
"assets/assets/plates/tapered-carrot-trouser.svg": "ae11a218ef62e5991a8dbc89803ca95c",
"assets/assets/plates/tapered-fit.svg": "1dfd8b5628dec2ad36d8e8ac3dbf9bea",
"assets/assets/plates/trail-runner.svg": "d865c1135a154602b1e45fd0e1b0c281",
"assets/assets/plates/trouser-break.svg": "ee672cb92bca440445b8a48adaddf552",
"assets/assets/plates/trucker-denim-jacket.svg": "78b46bf38053e1c51b314b42a81af334",
"assets/assets/plates/wide-leg-trouser.svg": "a8fffbf924cecf0f5a763e3a547acbad",
"assets/assets/plates/ma.svg": "9090987d44c99f7e812ea1c1c26bbd65",
"assets/assets/plates/ma-gap.svg": "dd0f8c04beabbad478ab393778d06fa3",
"assets/assets/fonts/Lora-Medium.ttf": "2c51d6c8fcac3ab587d74ec725c35c27",
"assets/assets/fonts/Nunito-Regular.ttf": "c15a3de8622bea5de54f467141bc2521",
"assets/assets/fonts/Lora-Regular.ttf": "5016349e9de4b2eeac85fa2ed374f7fe",
"assets/assets/fonts/Nunito-SemiBold.ttf": "33c704d4567fb8a57c7b1acb6fd658c0",
"assets/assets/fonts/Nunito-Bold.ttf": "fcd0055ad3f85db1b8ce73018ba8b7c6",
"assets/assets/fonts/Nunito-Medium.ttf": "92de69d6e4bac55d23b48b67ade9c225",
"assets/assets/fonts/Lora-Bold.ttf": "0cf62064521fb6e70f3ca2d6e37acab3",
"assets/assets/fonts/Lora-Italic.ttf": "0670dad11a0ba7369fccb78df6ac4ac5",
"assets/packages/openhearth_design/fonts/Lora-Regular.ttf": "5016349e9de4b2eeac85fa2ed374f7fe",
"assets/packages/openhearth_design/fonts/Lora-Italic.ttf": "0670dad11a0ba7369fccb78df6ac4ac5",
"assets/packages/openhearth_design/fonts/Lora-Medium.ttf": "2c51d6c8fcac3ab587d74ec725c35c27",
"assets/packages/openhearth_design/fonts/Lora-Bold.ttf": "0cf62064521fb6e70f3ca2d6e37acab3",
"assets/packages/openhearth_design/fonts/Nunito-Regular.ttf": "c15a3de8622bea5de54f467141bc2521",
"assets/packages/openhearth_design/fonts/Nunito-Medium.ttf": "92de69d6e4bac55d23b48b67ade9c225",
"assets/packages/openhearth_design/fonts/Nunito-SemiBold.ttf": "33c704d4567fb8a57c7b1acb6fd658c0",
"assets/packages/openhearth_design/fonts/Nunito-Bold.ttf": "fcd0055ad3f85db1b8ce73018ba8b7c6",
"assets/fonts/MaterialIcons-Regular.otf": "12d27754f7c317a810362925b41f72fe",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "7922ba6185813e58705ad986b2e8e867",
"assets/AssetManifest.bin.json": "12eb49d5c90c49a80bb307649168c90e",
"assets/NOTICES": "fcf7548d4498eb21062e3fc2c7b68307",
"assets/FontManifest.json": "e5b78e40bae49e07aa19c89ea773a264",
"favicon.png": "7950e64d75956f666dc39f5384cc1a5d",
"icons/Icon-192.png": "c967cf5f8f160df4e0b5f4020e3dba2d",
"icons/Icon-512.png": "9c7cdabe04b552665367a9f6f37a1ccc",
"icons/Icon-maskable-192.png": "f0430076703c55de1654078a6bdd1b33",
"icons/Icon-maskable-512.png": "8b5664adaaea1b8b6aa154cc0fe131fa",
"icons/mantle_icon.svg": "6fb61acdd810e60fe8bf636a09f0e5c4",
"sqlite3.wasm": "2e9fc1ccbb9d15199fccf405b0ceee53",
"drift_worker.js": "3a57681b52f6c68292ac63ab80a99eaa",
"manifest.json": "9fa7eb7996e48ff5bbd1c633b3217b97"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
