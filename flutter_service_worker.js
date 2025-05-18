'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "8f33dcf7f428acfbc10241b1ffcce900",
".git/config": "444342d3e917ad8859e1e9eb28111de9",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "7cf5170bffb51a57a530ad5aee90df99",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "f464905d74f067f20372f667ab1026e7",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "a63f86dfaae3559efaba2e73201a67b2",
".git/logs/refs/heads/gh-pages": "a63f86dfaae3559efaba2e73201a67b2",
".git/logs/refs/remotes/origin/gh-pages": "0ae60c6484bac2ca2beaede45bbf36de",
".git/logs/refs/remotes/origin/main": "4c4ff5f84504fe72da8de505ed3bfd80",
".git/objects/00/ddbd8c29bd5fcb947b377ca29329602279259d": "c840ec77823353a22a4bd78be9dd747c",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "80ba3eb567ab1b2327a13096a62dd17e",
".git/objects/04/6ef0c7dc98ac51323c5964671fe569a317a4db": "ae686fe048148ad5715bb74a8fa932f3",
".git/objects/08/e027bf429a67ecc11977766098ec5a6d775f0b": "a5b074c4946a07c0643ecf9779eef0fb",
".git/objects/09/3c21a59af3293a0f8add48be2e6ba8bf56b02b": "bec738ccbb995c0fea9822b6c3907464",
".git/objects/09/e95e382094cc65bc90b6449ad1e8c419bdc810": "f7a8ef31614a7ab7cb4bb7f0c77b14aa",
".git/objects/0c/d821b9b9e4578053d6aaea33379d021499c54b": "da29779dcfe2c864325f155587acb31c",
".git/objects/0d/5f1b483cc05ac832dd1f0d1dee25411dd38042": "bf82d73c2285f0ff0f453bd4837a4339",
".git/objects/0d/ba949fadadca049f58cbea62e71d560abd1c0d": "96666418ef902f30d78b4799070b7c98",
".git/objects/0f/779dc3d627db54754ffe67c2783a9a39ad6c27": "b9f73c384a423c630e32e8191497a523",
".git/objects/11/d1a726ac6136e039285264f3f7b37f1c31ffca": "5b577c7c55327ba5824d4f317dacac95",
".git/objects/17/7f8f7bd4f2748a175245eaee0f5cb09132e7eb": "1bf5edc47aa5f74e04fe01c21d62a146",
".git/objects/18/16fa5f2f352b4cbbe023f71df56f304554c5d4": "99f08ebaee4e096bfadcbe95c36a2536",
".git/objects/1c/8d98b8cc45346dd6913718364bb70948dd74da": "ceb4d4baa93bfa5f31f38861bb3d55eb",
".git/objects/1c/b74d59c78e9a548c779039804b669db997d622": "fec872bbc7c529ac4210e153a90b2923",
".git/objects/1c/f02f414e359dd762bf22fcfb0678ea93de6b68": "ca07cb04afce9c528f0739fcbfd38657",
".git/objects/1f/d8331cb77a03ccef312fd6f61597f16197c62c": "470584539c113aec71c1bf46221c3ffa",
".git/objects/23/01db6561ab1177d995a5b4c8bcd62c8fd2133c": "8b83af136dcfa81c5617cabe8775ee25",
".git/objects/24/512ba3dd287cc63ac7678478d92b1616bc9160": "3423d50e423522e19d874fddf771fe3b",
".git/objects/2a/477579e307dfbf86656677e9cd3b93e6309ae9": "16b71084944b0db77b588d142ed5706d",
".git/objects/2c/9b4ea457b818cbf8f9beb4ae5e52098e3768b8": "af8cf605ea511c56b5891e998c945099",
".git/objects/33/31d9290f04df89cea3fb794306a371fcca1cd9": "e54527b2478950463abbc6b22442144e",
".git/objects/33/8199d07f94363a65bd3f523cbc0c14aa0c602a": "66914f72f160cbb4a17c19ab29bee815",
".git/objects/33/ff4a6d64356533c689719f69eaa910532dc680": "cab4825da25244a880bc155cbbd73ef2",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/36/2f78bd2d0d6ab0bdce06064b3fcfa5b644e363": "7cb27c454b724de3e52b1cc37ff6a2f9",
".git/objects/3b/a1a937d4d09c8de99ba92cff7a1127ada7c75e": "1ed5651ee760eb17aa1e0c1376eb764c",
".git/objects/3d/2e3baeed9bd32dfc708db38f01099be62f4387": "372fd40f24bb72eeb58b8934f51426e2",
".git/objects/3f/0dae0e680c981db92bf42c73ed073079ffbc1a": "c28825fc565a5eb503743d624f1e5d1b",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/42/5d96eab883f70332ce793312a9facb8ec60bda": "7d995da3b75bb2bf65078367424dbb57",
".git/objects/45/5faead28da81c404964851fabe0b2eb696a44a": "371608863b9829267638caad82e91959",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/4a/d072f20b13bc3ee494869902ffbb44e7cdf046": "4a77523a809789a23bb8ec2d6d8b7f2d",
".git/objects/4c/7859a99bceb873a04f5d583e56ab3f99ac13de": "5b35f77be51385c8753c5312d6137ce6",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "254bc336602c9480c293f5f1c64bb4c7",
".git/objects/54/c77c3e72c909a2607939de3f7bc860f364551e": "d0fab45c1d7b4111fe77a9c8d36b086a",
".git/objects/56/0226f5aadf859c7920426b4c5b27e07c78ea67": "d3653ba7e540e768007034dff1f7099b",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/59/95097664d11062cc264ebcd3969aa0601c18a6": "1c3572a39a3b55e47d73a23a1d3514bb",
".git/objects/5a/c66284ccd34906a78b4a2486d911e1ec715b6c": "51902f3d61d259f01b260a225e665302",
".git/objects/5c/d671163703fcf4c21c432f0996307022431ee4": "e00a936f8b50f29622152a8eb490b657",
".git/objects/5d/faae13c3747a72c0e23d1b24157dd1d29276d7": "42edc14e4694f1706ce79ba0b4dd393a",
".git/objects/5e/f1ce3bad9be122e3b1be490c13690c00a891dd": "84315222a53428d2316eba17e4a72cc2",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/62/3b0a819d3153eb5a2bd1c9e3dec0fab5be5521": "3982837b6824f7a6ae5c10dc0da5e1cd",
".git/objects/64/5116c20530a7bd227658a3c51e004a3f0aefab": "f10b5403684ce7848d8165b3d1d5bbbe",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6c/7622f336d5b05d7ab8d3ace7e17fc7ccec8c2d": "728effeed951bdb6bda35fac77d25993",
".git/objects/6c/a9d40260f683df9cbaecac448e50059b5d5a77": "d4ca5dec72e095c1134d201a488db971",
".git/objects/6f/06d8a0869da6e20e361f2e3a0d404f96be5c91": "c29fb3d876e429aa4affbd4c8e4bcded",
".git/objects/70/db846b50233215c9c1557ea59033a014227b9b": "43455afe55e5368623f76c74e8f24613",
".git/objects/74/4fc2b1a78af097efe5a1f114dd925e33578a22": "0f9ba1a81e734244458649f9a424101e",
".git/objects/77/006e287e02955cdc9951e8e8799c0c674c9ea3": "58729e1ea27d4196cd47f62d985bac73",
".git/objects/7b/85831ede15cc8e235d9d303d8a889b7820fb57": "00c75e84f08d7665ad4050e39bad51f6",
".git/objects/7c/57aad8b7d8d9d46346a1897fbeb43dab42a016": "2c657952610e3d66a1f678f417f6fb25",
".git/objects/7f/7c5bdef1bc7149498d09b4f4a98d2f2635873e": "86486d31e182272b58f258d20e70d9a8",
".git/objects/81/b2621f31a51563a70c01399465660ad809d166": "fc27d1ccd7dc11ab3c43a30dd89b161c",
".git/objects/83/85b66285a60dcead4c128fced4b1beb665ee2d": "169bc63f5dfbc54dfb41063642c96b56",
".git/objects/83/ebda7e41c7f021f744038b55d5b1ad6a5b5484": "ac64b85ea06df157c11bdc7c4a6a1938",
".git/objects/84/997913cf1f498b13e25d1fcad2b8bf82d65539": "7d77561b9c4067e79b6415f5a5103dee",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8b/137891791fe96927ad78e64b0aad7bded08bdc": "9abb042e8c58ed4d703beb8e66b37150",
".git/objects/91/37fb6b47ee2f27c8be3312397930ea10ef0f8f": "e326217d2f183ea2a9902ea80bdfbe9a",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/93/be7fd9b9dcdd8564dafd7040a0c8c8f68d4080": "b27ff257c793a735fc818ff37f392ff9",
".git/objects/95/4a2d164365098161fd05f3cf8d26c0050c2019": "3fa4bbbed0405c350819e01b0576e3b2",
".git/objects/9b/f5b696db77e1468e69a254403c200114277bef": "725fb6b156ce20ec9a61faa7809339c3",
".git/objects/9f/372ae9e41922b4423311282164e2f6dfc5fc8d": "669c13f7771edd9d9b9cfd3358cee204",
".git/objects/a1/b51a17f1d12663e47571cb0726e98f54377d7c": "d20ee6927c96d2d577d7cc897cddff75",
".git/objects/a1/f518105ba759225f18e501bebfe24be39ba1cf": "6b8455103bb0d9e5adab468c7b4cf2d2",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a6/545e8982ccb1c7325727ab1a2d50d0ef1842a4": "6b020447507d13dd6068e9ceee989037",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/b3/62cc002895b8d5cdda1402907c0f2104695586": "871ec8479b0a070470a8edf402515c39",
".git/objects/b4/c8133e6d726a5a2f3b0be55397f68d82e5e89e": "e75a88065de34264a6e86c70bbe29772",
".git/objects/b9/f5eb79b5a094b5f595c4a6dfd83f3f54547445": "1a5dc3975bbe5d4c9493c5b40a438c65",
".git/objects/bd/97707038fade6d391ac4af58f86fff592edf5f": "03ae509be1414a7833ab30e9c7bfdab2",
".git/objects/c0/a8e0047338bbf40320155d8799ade451a3af30": "3498c460bfe013a829ab27068d71cb12",
".git/objects/c1/bd08a7826703449f185718f12db52680d89a46": "dd2482c8fd46be80d1a854aea1c88c39",
".git/objects/c7/fd51373c18f5ac773b48f79d23a19fe64b61ba": "2857dfcbf9f4911cd9b89b7d8edeb568",
".git/objects/c8/bcb03534ec7cb9ce0daad908a5e2e89b28c717": "b6d58ae77cc4a38c55e2a8c555bed206",
".git/objects/c8/c3a7a4f1123af17d0f39e43c3a4b40c36dd8af": "7f4bf148b43dae8c806b864079eb4163",
".git/objects/ca/ad490bfe716393ae9cd9cbd0aba5029cdd75a6": "08fa6ace7cf99b7544ce42bf55750a28",
".git/objects/cc/4945454854e1aa8be31019fcd953112c5d1807": "af52be622a29a2ad6208f29e162c2b4a",
".git/objects/ce/6346d2e0f1851cff454a7494cc6c7149a0b14e": "e3a646a626da54bf860f5368eaebf7e8",
".git/objects/d0/2085e3eae3841f1531549871fdc663f1438aae": "ecae4f35b2a245f720c8e96c0949dbbc",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/df/a4215e45a0f43bb1b13b9fe4306a586217b621": "922de73ec468eacf66a07303a714fa9d",
".git/objects/e3/4889568d676637dcb98768d3873a9f92184853": "c66bf3805c1bcdbb954f11bb99421f55",
".git/objects/e4/e18e71b87296cb180928a204c9937fe2b69599": "cf413df1c4d3431e747187dc759a6a58",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/e9/ba2022d4cbf59783e6248c5618fe68c9d50977": "b64e456a225bea3c416129e94785c8cf",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f4/6fae9908491d874df6c609bcf87d23132aeb3f": "21a3c34186279123bdd584c798987d98",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f7/09a8a17333c2c97f74555b30bd8291c3570504": "8a56990fefcd074999f75bdc5f4d525c",
".git/objects/f7/b729f5b12996541a274b4b01db72b8d8efed8c": "ff9437e74dd1ae4e9cf962199f9ded1c",
".git/objects/f8/439ba5e4a3fb60fecaccd3762442108a24f168": "101791ee2d1151874ba8e3b5d937a99f",
".git/objects/f8/f4f0f4e522f0273d39f8ac3be5385b345d3ebd": "e63df0872bf16dbf6201c6543e8c563f",
".git/objects/fa/50dfcee924fcb479717826adb7c39ddd6ebab4": "3726950dd16387926b56cc325dda5f7f",
".git/objects/fe/707fe035193d8b5dcc42fdc4e19d7d0749e3ee": "585addf410a51c5e91834cff834378bc",
".git/objects/pack/pack-4fa17dded15165fdb3ffa6a84ef126b7d06ba7ec.idx": "87c3f11e15449eabdabf9c66d3ef0bfb",
".git/objects/pack/pack-4fa17dded15165fdb3ffa6a84ef126b7d06ba7ec.pack": "6142f1433bbcde3d5303c1d802df0838",
".git/objects/pack/pack-4fa17dded15165fdb3ffa6a84ef126b7d06ba7ec.rev": "274a3e9f3428a2daa37864f9c13500b3",
".git/objects/pack/tmp_pack_QwcYD6": "316003998f53fbea2f4a92f36bd6734d",
".git/refs/heads/gh-pages": "f8eec431aeb0ab119684f333027173d2",
".git/refs/remotes/origin/gh-pages": "f8eec431aeb0ab119684f333027173d2",
".git/refs/remotes/origin/main": "1413dcd7ce3843fb21515dbf6b189a04",
"assets/AssetManifest.bin": "bdb979ea976142a013ae23a77da5f799",
"assets/AssetManifest.bin.json": "362afddf9825ec679c50a3b46b7045ac",
"assets/AssetManifest.json": "5d4db991733b87d40a23e3d7810f883c",
"assets/assets/Books/V1/V1_00-00.jpg": "93cda594e2fc3d50f51d914e47e574bf",
"assets/assets/Books/V1/V1_01-01.jpg": "0dccefa56832f2969ffcbca36102847e",
"assets/assets/Books/V1/V1_02-03.jpg": "243f407017938d3ef241188af97a8d21",
"assets/assets/Books/V1/V1_04-05.jpg": "19eb85fcb7e4caeff6b0ebbb512340f8",
"assets/assets/Books/V1/V1_06-07.jpg": "4445515d28dfe51a9fea950204d409dd",
"assets/assets/Books/V1/V1_08-09.jpg": "7a7d9469f1957ae93d690c3e5817eadc",
"assets/assets/Books/V1/V1_10-11.jpg": "02eebaf15594b5a2f3c9f60a8cf691a9",
"assets/assets/Books/V1/V1_12-13.jpg": "00019b54ff9a94d0064876249fe5b66d",
"assets/assets/Books/V1/V1_14-15.jpg": "4fa7a2e082828b1b51a4dccc4b72fb38",
"assets/assets/Books/V1/V1_16-17.jpg": "1127b4b3a7d9ef1cb36e8016b13c6eb9",
"assets/assets/Books/V1/V1_18-19.jpg": "9e38f690894df67ee77aef9c85186d01",
"assets/assets/Books/V1/V1_20-21.jpg": "62a61778b2fb14007167a672f5d1f7b0",
"assets/assets/Books/V1/V1_22-23.jpg": "b690a8d3938aa7d3a4f2ebd81c2f34cd",
"assets/assets/Books/V1/V1_24-25.jpg": "9014284fa1835b0a056e83ef0ed00a5c",
"assets/assets/Books/V1/V1_26-27.jpg": "2b57b3946419fa886a11fdf62cb23501",
"assets/assets/Books/V1/V1_28-29.jpg": "c04a5ce9b8d0184e2ee8ecedf255f0fb",
"assets/assets/Books/V1/V1_30-31.jpg": "6da5da0d0fcfc9dfbcfde927667b85f8",
"assets/assets/Books/V2/V2_00-00.jpg": "f53d0d9367a04310c64c78b7e27b4497",
"assets/assets/Books/V2/V2_01-01.jpg": "6115cfca2bf000ad486637ad2fff61ab",
"assets/assets/Books/V2/V2_02-03.jpg": "5170af1222bca94022bbc7cafb872f5e",
"assets/assets/Books/V2/V2_04-05.jpg": "c53fc7e5ba4792206dd7bf0cfa3eaeba",
"assets/assets/Books/V2/V2_06-07.jpg": "a99edec4a237819dd137032c71abdb32",
"assets/assets/Books/V2/V2_08-09.jpg": "fff8c96edc0f0d2ec1b9bbf539533895",
"assets/assets/Books/V2/V2_10-11.jpg": "f8e9b53194286015a059f09b3b7932cc",
"assets/assets/Books/V2/V2_12-13.jpg": "8a9bb26e158a79a7f879c355b47a178b",
"assets/assets/Books/V2/V2_14-15.jpg": "0ca1f3b92c12c396e243566ae7cc15b8",
"assets/assets/Books/V2/V2_16-17.jpg": "e064d2162a098920c3902fb726842935",
"assets/assets/Books/V2/V2_18-19.jpg": "fbbc2bf544da8eb4325fc38627973160",
"assets/assets/Books/V2/V2_20-21.jpg": "3db31acacdc41a03ea30bdfb2ff11eff",
"assets/assets/Books/V2/V2_22-23.jpg": "3ba52ba0809156a659127851f5329399",
"assets/assets/Books/V2/V2_24-25.jpg": "23fc3bc76c863a3c3629f7f9c7981c60",
"assets/assets/Books/V2/V2_26-27.jpg": "8d790315c7cb2bb2a8dc4625d07d2e48",
"assets/assets/Books/V2/V2_28-29.jpg": "7b442f2313a7943e13a337acf15f2458",
"assets/assets/Books/V2/V2_30-31.jpg": "531f5f4904fd6bce834273034ba531e9",
"assets/assets/Book_data/V1_book_data.json": "a85dbbd0d37f39f9ca24c2783c05e569",
"assets/assets/Book_data/V1_book_data.json.bak": "8fe9ecd0692dfecb7570d34243cfbfa5",
"assets/assets/Book_data/V1_vocabulary.json": "afb380c2671e48bfffd3d48ffcc995dc",
"assets/assets/Book_data/V2_book_data.json": "282c32ae858e279db296ec04b486982d",
"assets/assets/Book_data/V2_vocabulary.json": "b3615378d8265c7425fcaee0be37ffdd",
"assets/assets/icons/word_icon.svg": "20fd5fef0553c3d5fb3a12c7cdf3243e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "73c872cbeb041bbde645142c75a7a8c3",
"assets/NOTICES": "68b25fa1adad2e0535a9e668423fbe1a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_sound/assets/js/async_processor.js": "1665e1cb34d59d2769956d2f14290274",
"assets/packages/flutter_sound/assets/js/tau_web.js": "32cc693445f561133647b10d1b97ca07",
"assets/packages/flutter_sound_web/howler/howler.js": "3030c6101d2f8078546711db0d1a24e9",
"assets/packages/flutter_sound_web/src/flutter_sound.js": "3c26fcc60917c4cbaa6a30a231f7d4d8",
"assets/packages/flutter_sound_web/src/flutter_sound_player.js": "b14f8d190230d77c02ffc51ce962ce80",
"assets/packages/flutter_sound_web/src/flutter_sound_recorder.js": "0ec45f8c46d7ddb18691714c0c7348c8",
"assets/packages/flutter_sound_web/src/flutter_sound_stream_processor.js": "48d52b8f36a769ea0e90cf9e58eddfa7",
"assets/packages/record_web/assets/js/record.fixwebmduration.js": "1f0108ea80c8951ba702ced40cf8cdce",
"assets/packages/record_web/assets/js/record.worklet.js": "356bcfeddb8a625e3e2ba43ddf1cc13e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "79fb380cdfe864a389f015eede92a656",
"index.html": "76acb131a88dd6a62738562ef8d9acdc",
"/": "76acb131a88dd6a62738562ef8d9acdc",
"main.dart.js": "c13348a92a94a364e855ac9e31ca304c",
"manifest.json": "b9b1d88995876f5f244fa69aa7c11886",
"version.json": "e5ffb87a3a6149decc6c5f738e95e5df"};
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
