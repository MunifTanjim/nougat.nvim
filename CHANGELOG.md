# Changelog

## [0.4.0](https://github.com/MunifTanjim/nougat.nvim/compare/0.3.0...0.4.0) (2023-12-15)


### ⚠ BREAKING CHANGES

* **item:** deprecated config `.cache.invalidate` is removed, use `.cache.clear` instead.

### Features

* add entrypoint functions ([50393ad](https://github.com/MunifTanjim/nougat.nvim/commit/50393adfe375daef1f9891236fff24ca2d739471))
* **bar:** add ctx.breakpoint ([6e19fa4](https://github.com/MunifTanjim/nougat.nvim/commit/6e19fa495277bc5c8df54274f9f2e60b62d2b9cb))
* **cache:** use clearable store for buffer cache ([0807486](https://github.com/MunifTanjim/nougat.nvim/commit/0807486bd9a4ef0bfc7e8a5f84b2ad9d5b5725e0))
* **cache:** use clearable store for diagnostic cache ([56b8ff2](https://github.com/MunifTanjim/nougat.nvim/commit/56b8ff2d9ff278b3cd2f8aeb4d449d5e23736585))
* **color:** auto adjust with color scheme ([e0e7808](https://github.com/MunifTanjim/nougat.nvim/commit/e0e78084b8c88e9e733ac4e2e5cf391545c33909))
* **item:** remove deprecated config .cache.invalidate ([ced08cd](https://github.com/MunifTanjim/nougat.nvim/commit/ced08cd3c9cbd3701464d5c4aca9323f37869a6a))
* **item:** remove duplicate refs inside item config ([beeee91](https://github.com/MunifTanjim/nougat.nvim/commit/beeee91291ccf3e406de27ae24adacffe16d1aa8))
* **nut:** tweak buf.filestatus ([1a8a6d6](https://github.com/MunifTanjim/nougat.nvim/commit/1a8a6d66d2589d3adaf299b8e458449d9b1429d0))
* **store:** introduce nougat store ([3f23d3e](https://github.com/MunifTanjim/nougat.nvim/commit/3f23d3e01f7ecb254312f9ac0e32bee1e6e6b488))
* support winid for set_winbar ([375c2fb](https://github.com/MunifTanjim/nougat.nvim/commit/375c2fb805f20a03168d7c097a3eebf26a19ddcd))
* use clearable store for bars ([2d992a7](https://github.com/MunifTanjim/nougat.nvim/commit/2d992a7273bb904ebb4fb99e70350889b121be7d))
* **util:** do not add same callback twice for on_event ([da79bae](https://github.com/MunifTanjim/nougat.nvim/commit/da79bae1f80c2e915c9e86512909fcc124fbd9ec))
* **util:** use clearable store for on_event ([a4276c2](https://github.com/MunifTanjim/nougat.nvim/commit/a4276c24585357280f7974740bdbb85e4cf638ed))


### Bug Fixes

* **bar:** allow nested string[] for item w/ priority ([7801e77](https://github.com/MunifTanjim/nougat.nvim/commit/7801e77938850073c081874fd0567e8ae0dc31e1))
* **bar:** check item.content type properly ([c17e7b6](https://github.com/MunifTanjim/nougat.nvim/commit/c17e7b6ba2cd61ae1dd0447e4f022d6c57508a20))
* **bar:** missing slot.len for an edge case ([d9129e1](https://github.com/MunifTanjim/nougat.nvim/commit/d9129e1bd81f8f939700cb9e7fd76da6de9e693c))
* **bar:** missing slot.len for another edge case ([53f8fea](https://github.com/MunifTanjim/nougat.nvim/commit/53f8fea17cff165f91c32de8d083fce07652de8f))
* **bar:** priority item linking ([cd34b41](https://github.com/MunifTanjim/nougat.nvim/commit/cd34b41152cfbd59cf7faf2b523841db944098bb))
* **cache:** play nice with clearable store of on_event ([7fa5660](https://github.com/MunifTanjim/nougat.nvim/commit/7fa5660abb52216b5c49ee0f7743cec9564b5ee5))
* **color:** flakiness ([a555441](https://github.com/MunifTanjim/nougat.nvim/commit/a55544170b0faa92ae04cb9050817bda56896ccd))
* **item:** .cache.clear with single event ([d833dd7](https://github.com/MunifTanjim/nougat.nvim/commit/d833dd72dfbd092b4bff8562926bd0453b426ebd))
* **item:** nested items priority evaluation ([035dead](https://github.com/MunifTanjim/nougat.nvim/commit/035dead5c8d41f3bb7acd7ae1e3cc2b847bc4216))
* **item:** on_click for function content w/ parts ([4da137d](https://github.com/MunifTanjim/nougat.nvim/commit/4da137d636f1291aa87eddc0317311f36f088b70))
* **nut:** buf.diagnostic_count flicker ([1f0f65a](https://github.com/MunifTanjim/nougat.nvim/commit/1f0f65aebbf7490fceef7dde75f00f75cdb9629f))
* **nut:** handle missing devicons for tab.tablist.icon ([eebfb3d](https://github.com/MunifTanjim/nougat.nvim/commit/eebfb3d44ea7860e908f11890f5bd5b7779774da))
* **nut:** lsp.servers .config.sep position ([1268060](https://github.com/MunifTanjim/nougat.nvim/commit/12680601bc9b46884dce4b1963f91077904242f7))
* **profiler:** missing item for dynamic children ([e2ec089](https://github.com/MunifTanjim/nougat.nvim/commit/e2ec089b9b03ed0e3c9a546588678daa71b6869b))
* **separator:** none separator handling ([658dd2f](https://github.com/MunifTanjim/nougat.nvim/commit/658dd2fb337c4687b2565d173dcaf1a9ce66b6a2))


### Performance Improvements

* make hl name shorter ([6ca3170](https://github.com/MunifTanjim/nougat.nvim/commit/6ca31705277db02aa19574a38365dc8781436872))

## [0.3.0](https://github.com/MunifTanjim/nougat.nvim/compare/0.2.0...0.3.0) (2023-11-25)


### Features

* **bar:** add ctx.hl for current item hl ([8683545](https://github.com/MunifTanjim/nougat.nvim/commit/86835454b6212a6aaa4780d3882aaeca6612bc54))
* **bar:** keep reused tables isolated per bar ([5491005](https://github.com/MunifTanjim/nougat.nvim/commit/54910058fc90d86707b3b3c862bba936358782eb))
* **bar:** support hl config ([1e94e75](https://github.com/MunifTanjim/nougat.nvim/commit/1e94e75cbe6498101df2638c006ac992b046bdf7))
* **cache:** add buffer modifiable and readonly ([b77be4e](https://github.com/MunifTanjim/nougat.nvim/commit/b77be4e865b518020ac9cd10f0ce490a2ecfc2d8))
* **cache:** add method 'store:clear' ([5897b9f](https://github.com/MunifTanjim/nougat.nvim/commit/5897b9fe70ca4390ad3cd3e12418829c64c3d44e))
* **color:** add color palette ([d969995](https://github.com/MunifTanjim/nougat.nvim/commit/d9699952b65dd998b14feea6db46a3cbb3d59631))
* **item:** accept item as .hidden ([653686e](https://github.com/MunifTanjim/nougat.nvim/commit/653686e254bdd73e30c4a39d0a879be89f5f2a38))
* **item:** add config cache.name ([f56a564](https://github.com/MunifTanjim/nougat.nvim/commit/f56a564405dbc45c1aa48d2c4c97ce2137c13530))
* **item:** add item.ctx ([c840e8c](https://github.com/MunifTanjim/nougat.nvim/commit/c840e8ccb1f0870236846455a9aa90838ee2460a))
* **item:** add option 'cache.clear' ([bc16788](https://github.com/MunifTanjim/nougat.nvim/commit/bc16788827a52e0c4a7a8604fbe393eb9a7b3fda))
* **item:** support init callback ([ba54ea2](https://github.com/MunifTanjim/nougat.nvim/commit/ba54ea225c55826614ed8c4563b3399c836e304b))
* **nut:** add lsp.servers ([872166d](https://github.com/MunifTanjim/nougat.nvim/commit/872166d155271fbcd8ba0a7e40f51c137729005f))
* **nut:** use nougat.color ([e901a39](https://github.com/MunifTanjim/nougat.nvim/commit/e901a394b8ecdb111922aab668e8f6dd87749d1c))
* **profiler:** measure item perf ([7f7c5c0](https://github.com/MunifTanjim/nougat.nvim/commit/7f7c5c0eb388b3aaae7c95014ec199f81ef5d3fb))
* update command :Nougat ([06c370d](https://github.com/MunifTanjim/nougat.nvim/commit/06c370db771c4e9f9ce67a1c921a3f13f493dda7))
* **util:** add module nougat.util.hl ([7572323](https://github.com/MunifTanjim/nougat.nvim/commit/7572323c52e1010a6314592e498b37988deb3f89))
* **utils:** use weak table for object map ([6f95a04](https://github.com/MunifTanjim/nougat.nvim/commit/6f95a045b697856552b67ad1256bcd3f78c2660d))


### Bug Fixes

* **bar:** allow items to use ctx.parts ([b728db6](https://github.com/MunifTanjim/nougat.nvim/commit/b728db61edbead5ec5bae84128c679929f453d98))
* **item:** breakpoints for nested items ([cddf0df](https://github.com/MunifTanjim/nougat.nvim/commit/cddf0df402c167090b99ffd49fd544238022a967))
* **item:** on_click for function content ([b04e3d2](https://github.com/MunifTanjim/nougat.nvim/commit/b04e3d25a59c0e4e92c6b7b342fbed9f01dda8f4))
* **item:** safely access field ([667be3d](https://github.com/MunifTanjim/nougat.nvim/commit/667be3df84fc097e27c196d5ce894840e3a3ed21))
* **nut:** wordcount .hidden.if_not_filetype ([70b40c4](https://github.com/MunifTanjim/nougat.nvim/commit/70b40c401a433932e7c720aee3b5903b8a6bbfb4))
* **profiler:** item scoping typo ([8cb6aef](https://github.com/MunifTanjim/nougat.nvim/commit/8cb6aefde61c48b9f900f3dc6d233b3507b1a0bb))
* **profiler:** surface nested items ([dca1504](https://github.com/MunifTanjim/nougat.nvim/commit/dca150442a0699578623ffa9a255c84f3d43b6ff))
* **util:** consider .len for get_next_list_item ([3287317](https://github.com/MunifTanjim/nougat.nvim/commit/328731789b46b7199a8f6c88de8316b746d522d3))
* **util:** consider fallback separator highlight ([cbf03e3](https://github.com/MunifTanjim/nougat.nvim/commit/cbf03e35906862d6fd9f5af55ba00ba8388d2213))
* **util:** nested hl for priority items ([0772682](https://github.com/MunifTanjim/nougat.nvim/commit/0772682c2c1e9b074c76cfcda42d90f5c63e420e))
* **util:** parts slot hl mixup ([9d56b21](https://github.com/MunifTanjim/nougat.nvim/commit/9d56b217163152b2a1994ecafc7739407641e1fe))


### Performance Improvements

* **nut:** tweak cache for buf.filestatus ([994de44](https://github.com/MunifTanjim/nougat.nvim/commit/994de44a642f474d0ed15ce3b303373e32b0778c))
* **nut:** tweak cache for tab.tablist.icon ([2da5dca](https://github.com/MunifTanjim/nougat.nvim/commit/2da5dca75b7b9cbfcd146dbb55ada04f6c21a417))

## [0.2.0](https://github.com/MunifTanjim/nougat.nvim/compare/0.1.0...0.2.0) (2023-11-19)


### Features

* add on_event util ([d407874](https://github.com/MunifTanjim/nougat.nvim/commit/d407874a163b11f8b1414635ae7db4696c6e3a0e))
* **bar:** add 'items:next' interface for iteration ([a9fdb61](https://github.com/MunifTanjim/nougat.nvim/commit/a9fdb6107a92e36a4c76b50c8967001097deb29e))
* **bar:** support item priority ([6362246](https://github.com/MunifTanjim/nougat.nvim/commit/63622465301d14c3af301e3ead98ae21d46d577a))
* **bar:** update method add_item ([a588772](https://github.com/MunifTanjim/nougat.nvim/commit/a588772576829e40da5edc76623e62b914f9b8d9))
* **cache:** add .gitstatus to buffer cache ([c2d10f2](https://github.com/MunifTanjim/nougat.nvim/commit/c2d10f2259b5a00737338def3ab443440055ddd4))
* **cache:** add buffer filename ([3ab2c0a](https://github.com/MunifTanjim/nougat.nvim/commit/3ab2c0a8b7d233b4d80adc89e86423bae1f0cf12))
* **cache:** add more hooks ([4902e96](https://github.com/MunifTanjim/nougat.nvim/commit/4902e967cdf4b6328364f649497def85a91208b2))
* **cache:** support tab cache ([507dd2d](https://github.com/MunifTanjim/nougat.nvim/commit/507dd2deaaceaea223f9f107268512902feb274f))
* **core:** add nougat.core module ([9291fac](https://github.com/MunifTanjim/nougat.nvim/commit/9291fac6bd0323e9d7600d52ec4873ac0fc75b19))
* **item:** add cache config ([dba049f](https://github.com/MunifTanjim/nougat.nvim/commit/dba049fe50b2b3b07f446e66e6159b663650ee63))
* **item:** support priority config ([1b8ca44](https://github.com/MunifTanjim/nougat.nvim/commit/1b8ca446743608119c95dbe0e45c3a4f5c5305d7))
* **nut:** add .hidden.if_not_filetype for wordcount ([2b310ab](https://github.com/MunifTanjim/nougat.nvim/commit/2b310ab1eaec94e405727f36a1febf412405ca6c))
* **nut:** add .hidden.if_zero for diagnostic_count ([e820de1](https://github.com/MunifTanjim/nougat.nvim/commit/e820de186ffc00669aa454e54fcd93b4e5b47aa6))
* **nut:** add git.status ([aab870c](https://github.com/MunifTanjim/nougat.nvim/commit/aab870c6011ee77daf05633b1251993a2cfba787))
* **nut:** add truncation_point ([8eb4d4b](https://github.com/MunifTanjim/nougat.nvim/commit/8eb4d4be4c2f4e1d67fa5629a9baaf142b0e761c))
* **nut:** improve mode tracking ([413bb1f](https://github.com/MunifTanjim/nougat.nvim/commit/413bb1fda680dc67779c01f496ed6e477188be77))
* **nut:** remove fancy icon from tab.tablist.close ([daf4f15](https://github.com/MunifTanjim/nougat.nvim/commit/daf4f155ea703d04e095c2521b2281d8cf0611f8))
* **nut:** tweak some tab.tablist stuffs ([ea09613](https://github.com/MunifTanjim/nougat.nvim/commit/ea096136b6dd6edfe7dcecbd4ce8e0286b9355bc))
* **nut:** use cache config for caching ([45cc6e6](https://github.com/MunifTanjim/nougat.nvim/commit/45cc6e6ac8fb562ce3304c68041d655d9a4930c3))
* **separator:** improve hl processing ([3bf7f98](https://github.com/MunifTanjim/nougat.nvim/commit/3bf7f98b3825533acce904e4ce025133fb231bda))
* **separator:** make closest child hl automagic ([8755374](https://github.com/MunifTanjim/nougat.nvim/commit/8755374c9ee017c091b9f19c48dae2183a7d2f83))


### Bug Fixes

* **cache:** ignore diagnostic from invalid or scratch buffer ([edb59df](https://github.com/MunifTanjim/nougat.nvim/commit/edb59df603352b08796e58fb06cc0498033082ea))
* **item:** .on_click with function .content ([f31b5ec](https://github.com/MunifTanjim/nougat.nvim/commit/f31b5ecc426c9840930526b5fa12832ed8738a87))
* **nut:** fix buf.filename cache invalidation ([75ad4e9](https://github.com/MunifTanjim/nougat.nvim/commit/75ad4e98a9275a595d1136fa1b19a39ab2e235fd))
* **nut:** support priority in tab.tablist ([660aaf4](https://github.com/MunifTanjim/nougat.nvim/commit/660aaf4af2deeb69c18917fb88852d75d9810335))
* **nut:** tab.tablist.label ([ea3679c](https://github.com/MunifTanjim/nougat.nvim/commit/ea3679cf201b107e740b220f35497ec11001311a))
* **nut:** tab.tablist.label tabnr after tabmove ([ad7a20f](https://github.com/MunifTanjim/nougat.nvim/commit/ad7a20fd42ea1a3e16c96425c4089cbf73231af3))
* **nut:** wordcount in visual mode ([5818222](https://github.com/MunifTanjim/nougat.nvim/commit/58182225e56855e98d635027fb4560e825e3ef86))


### Performance Improvements

* **cache:** read filetype from autocmd params ([4a076aa](https://github.com/MunifTanjim/nougat.nvim/commit/4a076aa89ab3a23b9a37f222737d40db918b423b))
* **core:** reuse parts tables ([b2128a2](https://github.com/MunifTanjim/nougat.nvim/commit/b2128a2b1abba1c24cddad8b731889d763228c0e))

## 0.1.0 (2022-12-30)


### Features

* add 'hidden' prop for item ([09a6752](https://github.com/MunifTanjim/nougat.nvim/commit/09a67529ecadd362e341a5ca297546633ba5362c))
* add command :Nougat ([f3a88ad](https://github.com/MunifTanjim/nougat.nvim/commit/f3a88adf90e6a4c77d676d6aca2e348e58ad7948))
* **bar:** add helpers for statusline ([e0a173d](https://github.com/MunifTanjim/nougat.nvim/commit/e0a173d80aeb21a8f159e11cb5310e7a6a103c74))
* **bar:** add helpers for tabline ([82e270d](https://github.com/MunifTanjim/nougat.nvim/commit/82e270d91b04afb26bba602265ed8763765783c2))
* **bar:** add helpers for winbar ([199423e](https://github.com/MunifTanjim/nougat.nvim/commit/199423ea7a0eed0a219b2cf7ad1040d7e5de6bb4))
* **bar:** improve method add_item ([c922cda](https://github.com/MunifTanjim/nougat.nvim/commit/c922cdaa47b7e595bcd86c946c9999608749e3a5))
* **bar:** set local winbar by default ([a8daf71](https://github.com/MunifTanjim/nougat.nvim/commit/a8daf71631eb18f9bacae099eb7ec4488bd71aa6))
* **bar:** store bars in separate module ([a38493e](https://github.com/MunifTanjim/nougat.nvim/commit/a38493efbefca8d4e2d13f51633c1e8171056116))
* **bar:** update refresh_statusline default to focused only ([4d8d150](https://github.com/MunifTanjim/nougat.nvim/commit/4d8d150320366602261375ccca058e383de4ddb8))
* **bar:** use ctx.hls, process highlights once at the end ([01ad648](https://github.com/MunifTanjim/nougat.nvim/commit/01ad648ea9dea0349cc51c395b22e7b366314e13))
* **bar:** use ctx.parts, allow items to add parts ([d9e158a](https://github.com/MunifTanjim/nougat.nvim/commit/d9e158ad1108d1f7d1be5a3708a4986637cc3df9))
* **cache:** add buffer cache ([e9e6d3b](https://github.com/MunifTanjim/nougat.nvim/commit/e9e6d3b6920ae1f5d7b83986bd3a100d1a7e02a6))
* **cache:** add diagnostic cache ([739bb58](https://github.com/MunifTanjim/nougat.nvim/commit/739bb588b51ff8e7c493c5f2884dd0ef36c63674))
* initial implementation ([fac8f99](https://github.com/MunifTanjim/nougat.nvim/commit/fac8f9952cc456a1bf99bc2b54ff98bb0cd1162e))
* **item:** accept option .refresh ([ec131c2](https://github.com/MunifTanjim/nougat.nvim/commit/ec131c24b6b26ee8a59dbe90de128de39111d7c0))
* **item:** remove method item:generate ([5c41f49](https://github.com/MunifTanjim/nougat.nvim/commit/5c41f49be30b9053e769a48b30c2f06e49b78a97))
* **item:** remove type=ruler ([bbb49f5](https://github.com/MunifTanjim/nougat.nvim/commit/bbb49f5cfd89826da63f27f18a8db477586c33e9))
* **item:** remove type=spacer ([f7e46b0](https://github.com/MunifTanjim/nougat.nvim/commit/f7e46b0727e996b8877ae70ade1750254c330a22))
* **item:** rename method refresh -&gt; prepare ([035370e](https://github.com/MunifTanjim/nougat.nvim/commit/035370ebb757085e9f45f54cc809d75859eb47d7))
* **item:** support nested items ([103e100](https://github.com/MunifTanjim/nougat.nvim/commit/103e100c14079e2722ac43467948d7b45975a05c))
* **item:** support prefix/suffix function ([9536f50](https://github.com/MunifTanjim/nougat.nvim/commit/9536f50b9f9a290c1e209d51b13a5a12475f0cb3))
* **nut:** accept on_click and context ([654b9a4](https://github.com/MunifTanjim/nougat.nvim/commit/654b9a4a942b93ab876803942c15e17c4dbc7777))
* **nut:** add buf.diagnostic_count ([a8d2cd4](https://github.com/MunifTanjim/nougat.nvim/commit/a8d2cd457fc108fc27d73e31258405d5139eb587))
* **nut:** add buf.fileencoding ([8930674](https://github.com/MunifTanjim/nougat.nvim/commit/8930674059c5f7a3ca6db0c27c792bce4625acb6))
* **nut:** add buf.fileformat ([9516912](https://github.com/MunifTanjim/nougat.nvim/commit/9516912ed4a5e5dc7929f58dac1a3c347dbc4683))
* **nut:** add buf.filename ([58d85d1](https://github.com/MunifTanjim/nougat.nvim/commit/58d85d1e427b289861247aa8810f8ee6204471e4))
* **nut:** add buf.filestatus ([0986a7e](https://github.com/MunifTanjim/nougat.nvim/commit/0986a7e57770fdc099505c581b3cb41ee2d053b8))
* **nut:** add buf.filetype ([10d3084](https://github.com/MunifTanjim/nougat.nvim/commit/10d30844b6b22802be5059d741280f2229e14d0a))
* **nut:** add buf.wordcount ([eda5ea0](https://github.com/MunifTanjim/nougat.nvim/commit/eda5ea08ac3f472d98140cee0d1d98674a6904fa))
* **nut:** add config.unnamed for buf.filename ([a041836](https://github.com/MunifTanjim/nougat.nvim/commit/a041836fdfdc458a8e5e5b6bea35585a423e5844))
* **nut:** add default .hidden for diagnostic_count ([dd3a89a](https://github.com/MunifTanjim/nougat.nvim/commit/dd3a89a0107e7805347d7e58f30feed26373a869))
* **nut:** add diagnostic_count for tablist ([ad60e17](https://github.com/MunifTanjim/nougat.nvim/commit/ad60e1709a66415ed15df7af990b809bfa8263c4))
* **nut:** add git.branch ([0c433a3](https://github.com/MunifTanjim/nougat.nvim/commit/0c433a3349a511da22cf3c1d113faa0986de5d55))
* **nut:** add mode ([7939b40](https://github.com/MunifTanjim/nougat.nvim/commit/7939b408d4115aac0988da44ee425f70271491bf))
* **nut:** add opts.config.format for filename ([c08e549](https://github.com/MunifTanjim/nougat.nvim/commit/c08e549edb76f4c7e8f63fd83f0de99eec39cd71))
* **nut:** add opts.hidden for mode ([c680a0a](https://github.com/MunifTanjim/nougat.nvim/commit/c680a0a190c9ef66886c4e7024880078fc2b739b))
* **nut:** add ruler ([2d6b8cf](https://github.com/MunifTanjim/nougat.nvim/commit/2d6b8cfb101041cf4577674104be4537a11e3bbc))
* **nut:** add spacer ([ffb456e](https://github.com/MunifTanjim/nougat.nvim/commit/ffb456e9e1dae4b149a2c25429c76f03da389bd1))
* **nut:** add tab.tablist ([979a2bd](https://github.com/MunifTanjim/nougat.nvim/commit/979a2bd706de51423f9be8f2dbed703a8557b8ee))
* **nut:** diagnostic hl for tab.tablist.label ([e3d3d60](https://github.com/MunifTanjim/nougat.nvim/commit/e3d3d60609e4ecfec805ccc3cf29b67f6767f067))
* **nut:** make tab.tablist customizable and modular ([053db48](https://github.com/MunifTanjim/nougat.nvim/commit/053db48fe8f34dda0906859b2fde7fc00e3fafbb))
* **nut:** remove buf.wordcount default format config ([6fa847c](https://github.com/MunifTanjim/nougat.nvim/commit/6fa847cb0afd538a7e44b10edadc938885a0d9ab))
* **nut:** remove group from tab.tablist ([e3fc8f4](https://github.com/MunifTanjim/nougat.nvim/commit/e3fc8f478cbb95e11ca8dc14d6fa5eee12414e28))
* **nut:** use shared buffer cache ([5500b48](https://github.com/MunifTanjim/nougat.nvim/commit/5500b48d59bab3ebaf84ef4a2853a32688034cfc))
* **nut:** use simple char for default tab.tablist.modified ([cdac701](https://github.com/MunifTanjim/nougat.nvim/commit/cdac701b8de3441c4858cb4f081ece695d1c24d4))
* **profiler:** add bar.generator profiling ([431d50b](https://github.com/MunifTanjim/nougat.nvim/commit/431d50b90459ff3a4dd43cf94ceb160c757d828f))
* **profiler:** add bench function ([25a31fe](https://github.com/MunifTanjim/nougat.nvim/commit/25a31fe2619ac080e8d99a6af041d7f54abcdbd7))
* **separator:** add separator 'none' ([1ca6a2c](https://github.com/MunifTanjim/nougat.nvim/commit/1ca6a2c2921ff5937f67fc6aa257b1f262be07f6))
* **separator:** support closest child hl ([0feb61c](https://github.com/MunifTanjim/nougat.nvim/commit/0feb61c0f0bd8503b91104f531fdde717bac3c37))
* **separator:** support hl function ([dc9c2aa](https://github.com/MunifTanjim/nougat.nvim/commit/dc9c2aaad0aa36112b2a9c858819bc727cceb762))
* support breakpoints ([04a27c9](https://github.com/MunifTanjim/nougat.nvim/commit/04a27c90cc2e3a1aea523b532d2a69ea1b957f52))
* **util:** add .len to return value of prepare_parts ([831b606](https://github.com/MunifTanjim/nougat.nvim/commit/831b606cd0ab3d76613083b31d2789fc0c6fb056))
* **util:** support content parts in prepare_parts ([c38ee59](https://github.com/MunifTanjim/nougat.nvim/commit/c38ee59378805204792839a0e8c09f593b9a1c6d))


### Bug Fixes

* **cache:** deepcopy default_value before using ([cd46b6f](https://github.com/MunifTanjim/nougat.nvim/commit/cd46b6ff4d07b17e2f83628305681833f3136158))
* **util:** guard against missing bg/fg ([7337c6d](https://github.com/MunifTanjim/nougat.nvim/commit/7337c6d91c1d21933a8c13de626a71954300ddae))
* **util:** prefix discard index handling ([784055b](https://github.com/MunifTanjim/nougat.nvim/commit/784055b85fb65206237b509fce5decbdb1dbc501))


### Performance Improvements

* **nut:** decrease string concat for tablist ([71c096e](https://github.com/MunifTanjim/nougat.nvim/commit/71c096ebbffa463e0c82db06862807f7cf1c08e6))
* **nut:** decrease tab ctx nesting for tablist ([21ab4a6](https://github.com/MunifTanjim/nougat.nvim/commit/21ab4a698e29076a3c537b2b6651c50b8db79d27))
* **nut:** decrease table creation for tab.tablist ([7ddcf2f](https://github.com/MunifTanjim/nougat.nvim/commit/7ddcf2f4e2871352fac29587204840b5aad97d0f))
* replace slow vim.{b,bo,wo,go} with function calls ([3d42eaa](https://github.com/MunifTanjim/nougat.nvim/commit/3d42eaa5faea29d55db81f15e909e401057798b7))
* **util:** use core.add_highlight instead of core.highlight ([2ab5620](https://github.com/MunifTanjim/nougat.nvim/commit/2ab562060facbfe048f2766571d5b7b44444e287))
* **util:** use local functions ([8fb3bd4](https://github.com/MunifTanjim/nougat.nvim/commit/8fb3bd44923886c97d4b090ea1af211b045dd8fd))


### Continuous Integration

* introduce automated release ([58229f1](https://github.com/MunifTanjim/nougat.nvim/commit/58229f19d6f877ff1c855ae944f7161ea12b8b94))
