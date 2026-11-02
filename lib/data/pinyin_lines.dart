/// 已知带人工拼音标注的诗词（见 data/README.md 的拼音标注说明）。
/// 其余诗词的拼音由构建流程基于原文用拼音库自动生成，这里不手打。
/// 格式沿用原型稿的紧凑写法："字/拼音 字/拼音 ，" 标点无拼音。
const Map<String, List<String>> pinyinLines = {
  'qyc-xue': [
    '北/běi 国/guó 风/fēng 光/guāng ， 千/qiān 里/lǐ 冰/bīng 封/fēng ， 万/wàn 里/lǐ 雪/xuě 飘/piāo 。',
    '望/wàng 长/cháng 城/chéng 内/nèi 外/wài ， 惟/wéi 余/yú 莽/mǎng 莽/mǎng ； 大/dà 河/hé 上/shàng 下/xià ， 顿/dùn 失/shī 滔/tāo 滔/tāo 。',
    '山/shān 舞/wǔ 银/yín 蛇/shé ， 原/yuán 驰/chí 蜡/là 象/xiàng ， 欲/yù 与/yǔ 天/tiān 公/gōng 试/shì 比/bǐ 高/gāo 。',
    '须/xū 晴/qíng 日/rì ， 看/kàn 红/hóng 装/zhuāng 素/sù 裹/guǒ ， 分/fèn 外/wài 妖/yāo 娆/ráo 。',
    '江/jiāng 山/shān 如/rú 此/cǐ 多/duō 娇/jiāo ， 引/yǐn 无/wú 数/shù 英/yīng 雄/xióng 竞/jìng 折/zhé 腰/yāo 。',
    '惜/xī 秦/qín 皇/huáng 汉/hàn 武/wǔ ， 略/lüè 输/shū 文/wén 采/cǎi ； 唐/táng 宗/zōng 宋/sòng 祖/zǔ ， 稍/shāo 逊/xùn 风/fēng 骚/sāo 。',
    '一/yí 代/dài 天/tiān 骄/jiāo ， 成/chéng 吉/jí 思/sī 汗/hán ， 只/zhǐ 识/shí 弯/wān 弓/gōng 射/shè 大/dà 雕/diāo 。',
    '俱/jù 往/wǎng 矣/yǐ ， 数/shǔ 风/fēng 流/liú 人/rén 物/wù ， 还/hái 看/kàn 今/jīn 朝/zhāo 。',
  ],
  'qlcz': [
    '红/hóng 军/jūn 不/bú 怕/pà 远/yuǎn 征/zhēng 难/nán ， 万/wàn 水/shuǐ 千/qiān 山/shān 只/zhǐ 等/děng 闲/xián 。',
    '五/wǔ 岭/lǐng 逶/wēi 迤/yí 腾/téng 细/xì 浪/làng ， 乌/wū 蒙/méng 磅/páng 礴/bó 走/zǒu 泥/ní 丸/wán 。',
    '金/jīn 沙/shā 水/shuǐ 拍/pāi 云/yún 崖/yá 暖/nuǎn ， 大/dà 渡/dù 桥/qiáo 横/héng 铁/tiě 索/suǒ 寒/hán 。',
    '更/gèng 喜/xǐ 岷/mín 山/shān 千/qiān 里/lǐ 雪/xuě ， 三/sān 军/jūn 过/guò 后/hòu 尽/jìn 开/kāi 颜/yán 。',
  ],
  'bsz-ym': [
    '风/fēng 雨/yǔ 送/sòng 春/chūn 归/guī ， 飞/fēi 雪/xuě 迎/yíng 春/chūn 到/dào 。',
    '已/yǐ 是/shì 悬/xuán 崖/yá 百/bǎi 丈/zhàng 冰/bīng ， 犹/yóu 有/yǒu 花/huā 枝/zhī 俏/qiào 。',
    '俏/qiào 也/yě 不/bù 争/zhēng 春/chūn ， 只/zhǐ 把/bǎ 春/chūn 来/lái 报/bào 。',
    '待/dài 到/dào 山/shān 花/huā 烂/làn 漫/màn 时/shí ， 她/tā 在/zài 丛/cóng 中/zhōng 笑/xiào 。',
  ],
};
