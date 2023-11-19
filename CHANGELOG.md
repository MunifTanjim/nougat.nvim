# Changelog

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
