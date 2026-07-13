package org.csc.myprogram.service;

import java.util.ArrayList;
import java.util.List;

import org.csc.myprogram.entity.CityInfo;

/**
 * 中国城市数据库 - 覆盖全国地级市、县级市及主要区县
 * 支持中文和拼音模糊搜索
 */
public class CityDatabase {

    private static final List<CityInfo> CITIES = new ArrayList<>();

    static {
        // ===== 直辖市 =====
        addCity("北京", "北京市", "北京", "101010100", "beijing");
        addCity("朝阳", "北京市", "北京", "101010300", "chaoyang");
        addCity("海淀", "北京市", "北京", "101010200", "haidian");
        addCity("丰台", "北京市", "北京", "101010900", "fengtai");
        addCity("石景山", "北京市", "北京", "101010400", "shijingshan");
        addCity("通州", "北京市", "北京", "101010600", "tongzhou");
        addCity("顺义", "北京市", "北京", "101010500", "shunyi");
        addCity("昌平", "北京市", "北京", "101010700", "changping");
        addCity("大兴", "北京市", "北京", "101010800", "daxing");
        addCity("房山", "北京市", "北京", "101011000", "fangshan");
        addCity("门头沟", "北京市", "北京", "101011100", "mentougou");
        addCity("平谷", "北京市", "北京", "101011200", "pinggu");
        addCity("怀柔", "北京市", "北京", "101011300", "huairou");
        addCity("密云", "北京市", "北京", "101011400", "miyun");
        addCity("延庆", "北京市", "北京", "101011500", "yanqing");

        addCity("上海", "上海市", "上海", "101020100", "shanghai");
        addCity("浦东新区", "上海市", "上海", "101020600", "pudongxinqu");
        addCity("闵行", "上海市", "上海", "101020200", "minhang");
        addCity("宝山", "上海市", "上海", "101020300", "baoshan");
        addCity("嘉定", "上海市", "上海", "101020500", "jiading");
        addCity("松江", "上海市", "上海", "101020700", "songjiang");
        addCity("青浦", "上海市", "上海", "101020800", "qingpu");
        addCity("奉贤", "上海市", "上海", "101020900", "fengxian");
        addCity("金山", "上海市", "上海", "101021000", "jinshan");
        addCity("崇明", "上海市", "上海", "101021100", "chongming");

        addCity("天津", "天津市", "天津", "101030100", "tianjin");
        addCity("武清", "天津市", "天津", "101030300", "wuqing");
        addCity("宝坻", "天津市", "天津", "101030400", "baodi");
        addCity("宁河", "天津市", "天津", "101030500", "ninghe");
        addCity("静海", "天津市", "天津", "101030600", "jinghai");
        addCity("蓟州", "天津市", "天津", "101030700", "jizhou");

        addCity("重庆", "重庆市", "重庆", "101040100", "chongqing");
        addCity("万州", "重庆市", "重庆", "101040200", "wanzhou");
        addCity("涪陵", "重庆市", "重庆", "101040300", "fuling");
        addCity("永川", "重庆市", "重庆", "101040600", "yongchuan");
        addCity("江津", "重庆市", "重庆", "101040700", "jiangjin");
        addCity("合川", "重庆市", "重庆", "101040800", "hechuan");

        // ===== 河北省 =====
        addCity("石家庄", "河北省", "石家庄", "101090101", "shijiazhuang");
        addCity("唐山", "河北省", "唐山", "101090501", "tangshan");
        addCity("秦皇岛", "河北省", "秦皇岛", "101091101", "qinhuangdao");
        addCity("邯郸", "河北省", "邯郸", "101091001", "handan");
        addCity("邢台", "河北省", "邢台", "101090901", "xingtai");
        addCity("保定", "河北省", "保定", "101090201", "baoding");
        addCity("张家口", "河北省", "张家口", "101090301", "zhangjiakou");
        addCity("承德", "河北省", "承德", "101090401", "chengde");
        addCity("沧州", "河北省", "沧州", "101090701", "cangzhou");
        addCity("廊坊", "河北省", "廊坊", "101090601", "langfang");
        addCity("衡水", "河北省", "衡水", "101090801", "hengshui");

        // ===== 山西省 =====
        addCity("太原", "山西省", "太原", "101100101", "taiyuan");
        addCity("大同", "山西省", "大同", "101100201", "datong");
        addCity("阳泉", "山西省", "阳泉", "101100301", "yangquan");
        addCity("长治", "山西省", "长治", "101100501", "changzhi");
        addCity("晋城", "山西省", "晋城", "101100601", "jincheng");
        addCity("朔州", "山西省", "朔州", "101100801", "shuozhou");
        addCity("晋中", "山西省", "晋中", "101100401", "jinzhong");
        addCity("运城", "山西省", "运城", "101100701", "yuncheng");
        addCity("忻州", "山西省", "忻州", "101100901", "xinzhou");
        addCity("临汾", "山西省", "临汾", "101101001", "linfen");
        addCity("吕梁", "山西省", "吕梁", "101101101", "lvliang");

        // ===== 内蒙古 =====
        addCity("呼和浩特", "内蒙古", "呼和浩特", "101080101", "huhehaote");
        addCity("包头", "内蒙古", "包头", "101080201", "baotou");
        addCity("乌海", "内蒙古", "乌海", "101080301", "wuhai");
        addCity("赤峰", "内蒙古", "赤峰", "101080401", "chifeng");
        addCity("通辽", "内蒙古", "通辽", "101080501", "tongliao");
        addCity("鄂尔多斯", "内蒙古", "鄂尔多斯", "101080601", "eerduosi");
        addCity("呼伦贝尔", "内蒙古", "呼伦贝尔", "101080701", "hulunbeier");
        addCity("巴彦淖尔", "内蒙古", "巴彦淖尔", "101080801", "bayannaoer");
        addCity("乌兰察布", "内蒙古", "乌兰察布", "101080901", "wulanchabu");
        addCity("兴安盟", "内蒙古", "兴安盟", "101081001", "xinganmeng");
        addCity("锡林郭勒盟", "内蒙古", "锡林郭勒盟", "101081101", "xilinguolemeng");
        addCity("阿拉善盟", "内蒙古", "阿拉善盟", "101081201", "alashanmeng");

        // ===== 辽宁省 =====
        addCity("沈阳", "辽宁省", "沈阳", "101070101", "shenyang");
        addCity("大连", "辽宁省", "大连", "101070201", "dalian");
        addCity("鞍山", "辽宁省", "鞍山", "101070301", "anshan");
        addCity("抚顺", "辽宁省", "抚顺", "101070401", "fushun");
        addCity("本溪", "辽宁省", "本溪", "101070501", "benxi");
        addCity("丹东", "辽宁省", "丹东", "101070601", "dandong");
        addCity("锦州", "辽宁省", "锦州", "101070701", "jinzhou");
        addCity("营口", "辽宁省", "营口", "101070801", "yingkou");
        addCity("阜新", "辽宁省", "阜新", "101070901", "fuxin");
        addCity("辽阳", "辽宁省", "辽阳", "101071001", "liaoyang");
        addCity("盘锦", "辽宁省", "盘锦", "101071101", "panjin");
        addCity("铁岭", "辽宁省", "铁岭", "101071201", "tieling");
        addCity("朝阳", "辽宁省", "朝阳", "101071301", "chaoyang");
        addCity("葫芦岛", "辽宁省", "葫芦岛", "101071401", "huludao");

        // ===== 吉林省 =====
        addCity("长春", "吉林省", "长春", "101060101", "changchun");
        addCity("吉林", "吉林省", "吉林", "101060201", "jilin");
        addCity("四平", "吉林省", "四平", "101060301", "siping");
        addCity("辽源", "吉林省", "辽源", "101060401", "liaoyuan");
        addCity("通化", "吉林省", "通化", "101060501", "tonghua");
        addCity("白山", "吉林省", "白山", "101060601", "baishan");
        addCity("松原", "吉林省", "松原", "101060701", "songyuan");
        addCity("白城", "吉林省", "白城", "101060801", "baicheng");
        addCity("延边", "吉林省", "延边", "101060901", "yanbian");

        // ===== 黑龙江省 =====
        addCity("哈尔滨", "黑龙江省", "哈尔滨", "101050101", "haerbin");
        addCity("齐齐哈尔", "黑龙江省", "齐齐哈尔", "101050201", "qiqihaer");
        addCity("鸡西", "黑龙江省", "鸡西", "101050301", "jixi");
        addCity("鹤岗", "黑龙江省", "鹤岗", "101050401", "hegang");
        addCity("双鸭山", "黑龙江省", "双鸭山", "101050501", "shuangyashan");
        addCity("大庆", "黑龙江省", "大庆", "101050601", "daqing");
        addCity("伊春", "黑龙江省", "伊春", "101050701", "yichun");
        addCity("佳木斯", "黑龙江省", "佳木斯", "101050801", "jiamusi");
        addCity("七台河", "黑龙江省", "七台河", "101050901", "qitaihe");
        addCity("牡丹江", "黑龙江省", "牡丹江", "101051001", "mudanjiang");
        addCity("黑河", "黑龙江省", "黑河", "101051101", "heihe");
        addCity("绥化", "黑龙江省", "绥化", "101051201", "suihua");
        addCity("大兴安岭", "黑龙江省", "大兴安岭", "101051301", "daxinganling");

        // ===== 江苏省 =====
        addCity("南京", "江苏省", "南京", "101190101", "nanjing");
        addCity("无锡", "江苏省", "无锡", "101190201", "wuxi");
        addCity("镇江", "江苏省", "镇江", "101190301", "zhenjiang");
        addCity("苏州", "江苏省", "苏州", "101190401", "suzhou");
        addCity("南通", "江苏省", "南通", "101190501", "nantong");
        addCity("扬州", "江苏省", "扬州", "101190601", "yangzhou");
        addCity("盐城", "江苏省", "盐城", "101190701", "yancheng");
        addCity("徐州", "江苏省", "徐州", "101190801", "xuzhou");
        addCity("淮安", "江苏省", "淮安", "101190901", "huaian");
        addCity("连云港", "江苏省", "连云港", "101191001", "lianyungang");
        addCity("常州", "江苏省", "常州", "101191101", "changzhou");
        addCity("泰州", "江苏省", "泰州", "101191201", "taizhou");
        addCity("宿迁", "江苏省", "宿迁", "101191301", "suqian");

        // ===== 浙江省 =====
        addCity("杭州", "浙江省", "杭州", "101210101", "hangzhou");
        addCity("湖州", "浙江省", "湖州", "101210201", "huzhou");
        addCity("嘉兴", "浙江省", "嘉兴", "101210301", "jiaxing");
        addCity("宁波", "浙江省", "宁波", "101210401", "ningbo");
        addCity("绍兴", "浙江省", "绍兴", "101210501", "shaoxing");
        addCity("温州", "浙江省", "温州", "101210601", "wenzhou");
        addCity("丽水", "浙江省", "丽水", "101210701", "lishui");
        addCity("金华", "浙江省", "金华", "101210901", "jinhua");
        addCity("衢州", "浙江省", "衢州", "101211001", "quzhou");
        addCity("台州", "浙江省", "台州", "101210801", "taizhou");
        addCity("舟山", "浙江省", "舟山", "101211101", "zhoushan");

        // ===== 安徽省 =====
        addCity("合肥", "安徽省", "合肥", "101220101", "hefei");
        addCity("蚌埠", "安徽省", "蚌埠", "101220201", "bengbu");
        addCity("芜湖", "安徽省", "芜湖", "101220301", "wuhu");
        addCity("淮南", "安徽省", "淮南", "101220401", "huainan");
        addCity("马鞍山", "安徽省", "马鞍山", "101220501", "maanshan");
        addCity("安庆", "安徽省", "安庆", "101220601", "anqing");
        addCity("宿州", "安徽省", "宿州", "101220701", "suzhou");
        addCity("阜阳", "安徽省", "阜阳", "101220801", "fuyang");
        addCity("亳州", "安徽省", "亳州", "101220901", "bozhou");
        addCity("黄山", "安徽省", "黄山", "101221001", "huangshan");
        addCity("滁州", "安徽省", "滁州", "101221101", "chuzhou");
        addCity("淮北", "安徽省", "淮北", "101221201", "huaibei");
        addCity("铜陵", "安徽省", "铜陵", "101221301", "tongling");
        addCity("宣城", "安徽省", "宣城", "101221401", "xuancheng");
        addCity("六安", "安徽省", "六安", "101221501", "luan");
        addCity("池州", "安徽省", "池州", "101221701", "chizhou");

        // ===== 福建省 =====
        addCity("福州", "福建省", "福州", "101230101", "fuzhou");
        addCity("厦门", "福建省", "厦门", "101230201", "xiamen");
        addCity("宁德", "福建省", "宁德", "101230301", "ningde");
        addCity("莆田", "福建省", "莆田", "101230401", "putian");
        addCity("泉州", "福建省", "泉州", "101230501", "quanzhou");
        addCity("漳州", "福建省", "漳州", "101230601", "zhangzhou");
        addCity("龙岩", "福建省", "龙岩", "101230701", "longyan");
        addCity("三明", "福建省", "三明", "101230801", "sanming");
        addCity("南平", "福建省", "南平", "101230901", "nanping");

        // ===== 江西省 =====
        addCity("南昌", "江西省", "南昌", "101240101", "nanchang");
        addCity("九江", "江西省", "九江", "101240201", "jiujiang");
        addCity("上饶", "江西省", "上饶", "101240301", "shangrao");
        addCity("抚州", "江西省", "抚州", "101240401", "fuzhou");
        addCity("宜春", "江西省", "宜春", "101240501", "yichun");
        addCity("吉安", "江西省", "吉安", "101240601", "jian");
        addCity("赣州", "江西省", "赣州", "101240701", "ganzhou");
        addCity("景德镇", "江西省", "景德镇", "101240801", "jingdezhen");
        addCity("萍乡", "江西省", "萍乡", "101240901", "pingxiang");
        addCity("新余", "江西省", "新余", "101241001", "xinyu");
        addCity("鹰潭", "江西省", "鹰潭", "101241101", "yingtan");

        // ===== 山东省 =====
        addCity("济南", "山东省", "济南", "101120101", "jinan");
        addCity("青岛", "山东省", "青岛", "101120201", "qingdao");
        addCity("淄博", "山东省", "淄博", "101120301", "zibo");
        addCity("德州", "山东省", "德州", "101120401", "dezhou");
        addCity("烟台", "山东省", "烟台", "101120501", "yantai");
        addCity("潍坊", "山东省", "潍坊", "101120601", "weifang");
        addCity("济宁", "山东省", "济宁", "101120701", "jining");
        addCity("泰安", "山东省", "泰安", "101120801", "taian");
        addCity("临沂", "山东省", "临沂", "101120901", "linyi");
        addCity("菏泽", "山东省", "菏泽", "101121001", "heze");
        addCity("滨州", "山东省", "滨州", "101121101", "binzhou");
        addCity("东营", "山东省", "东营", "101121201", "dongying");
        addCity("威海", "山东省", "威海", "101121301", "weihai");
        addCity("枣庄", "山东省", "枣庄", "101121401", "zaozhuang");
        addCity("日照", "山东省", "日照", "101121501", "rizhao");
        addCity("聊城", "山东省", "聊城", "101121701", "liaocheng");

        // ===== 河南省 =====
        addCity("郑州", "河南省", "郑州", "101180101", "zhengzhou");
        addCity("安阳", "河南省", "安阳", "101180201", "anyang");
        addCity("新乡", "河南省", "新乡", "101180301", "xinxiang");
        addCity("许昌", "河南省", "许昌", "101180401", "xuchang");
        addCity("平顶山", "河南省", "平顶山", "101180501", "pingdingshan");
        addCity("信阳", "河南省", "信阳", "101180601", "xinyang");
        addCity("南阳", "河南省", "南阳", "101180701", "nanyang");
        addCity("开封", "河南省", "开封", "101180801", "kaifeng");
        addCity("洛阳", "河南省", "洛阳", "101180901", "luoyang");
        addCity("商丘", "河南省", "商丘", "101181001", "shangqiu");
        addCity("焦作", "河南省", "焦作", "101181101", "jiaozuo");
        addCity("鹤壁", "河南省", "鹤壁", "101181201", "hebi");
        addCity("濮阳", "河南省", "濮阳", "101181301", "puyang");
        addCity("周口", "河南省", "周口", "101181401", "zhoukou");
        addCity("漯河", "河南省", "漯河", "101181501", "luohe");
        addCity("驻马店", "河南省", "驻马店", "101181601", "zhumadian");
        addCity("三门峡", "河南省", "三门峡", "101181701", "sanmenxia");

        // ===== 湖北省 =====
        addCity("武汉", "湖北省", "武汉", "101200101", "wuhan");
        addCity("襄阳", "湖北省", "襄阳", "101200201", "xiangyang");
        addCity("鄂州", "湖北省", "鄂州", "101200301", "ezhou");
        addCity("孝感", "湖北省", "孝感", "101200401", "xiaogan");
        addCity("黄冈", "湖北省", "黄冈", "101200501", "huanggang");
        addCity("黄石", "湖北省", "黄石", "101200601", "huangshi");
        addCity("咸宁", "湖北省", "咸宁", "101200701", "xianning");
        addCity("荆州", "湖北省", "荆州", "101200801", "jingzhou");
        addCity("宜昌", "湖北省", "宜昌", "101200901", "yichang");
        addCity("恩施", "湖北省", "恩施", "101201001", "enshi");
        addCity("十堰", "湖北省", "十堰", "101201101", "shiyan");
        addCity("神农架", "湖北省", "神农架", "101201201", "shennongjia");
        addCity("随州", "湖北省", "随州", "101201301", "suizhou");
        addCity("荆门", "湖北省", "荆门", "101201401", "jingmen");
        addCity("天门", "湖北省", "天门", "101201501", "tianmen");
        addCity("仙桃", "湖北省", "仙桃", "101201601", "xiantao");
        addCity("潜江", "湖北省", "潜江", "101201701", "qianjiang");

        // ===== 湖南省 =====
        addCity("长沙", "湖南省", "长沙", "101250101", "changsha");
        addCity("湘潭", "湖南省", "湘潭", "101250201", "xiangtan");
        addCity("株洲", "湖南省", "株洲", "101250401", "zhuzhou");
        addCity("衡阳", "湖南省", "衡阳", "101250501", "hengyang");
        addCity("郴州", "湖南省", "郴州", "101250701", "chenzhou");
        addCity("常德", "湖南省", "常德", "101250601", "changde");
        addCity("益阳", "湖南省", "益阳", "101250801", "yiyang");
        addCity("娄底", "湖南省", "娄底", "101250901", "loudi");
        addCity("邵阳", "湖南省", "邵阳", "101251001", "shaoyang");
        addCity("岳阳", "湖南省", "岳阳", "101250301", "yueyang");
        addCity("张家界", "湖南省", "张家界", "101251101", "zhangjiajie");
        addCity("怀化", "湖南省", "怀化", "101251201", "huaihua");
        addCity("永州", "湖南省", "永州", "101251401", "yongzhou");
        addCity("湘西", "湖南省", "湘西", "101251501", "xiangxi");

        // ===== 广东省 =====
        addCity("广州", "广东省", "广州", "101280101", "guangzhou");
        addCity("韶关", "广东省", "韶关", "101280201", "shaoguan");
        addCity("惠州", "广东省", "惠州", "101280301", "huizhou");
        addCity("梅州", "广东省", "梅州", "101280401", "meizhou");
        addCity("汕头", "广东省", "汕头", "101280501", "shantou");
        addCity("深圳", "广东省", "深圳", "101280601", "shenzhen");
        addCity("珠海", "广东省", "珠海", "101280701", "zhuhai");
        addCity("佛山", "广东省", "佛山", "101280800", "foshan");
        addCity("肇庆", "广东省", "肇庆", "101280901", "zhaoqing");
        addCity("湛江", "广东省", "湛江", "101281001", "zhanjiang");
        addCity("江门", "广东省", "江门", "101281101", "jiangmen");
        addCity("河源", "广东省", "河源", "101281201", "heyuan");
        addCity("清远", "广东省", "清远", "101281301", "qingyuan");
        addCity("云浮", "广东省", "云浮", "101281401", "yunfu");
        addCity("潮州", "广东省", "潮州", "101281501", "chaozhou");
        addCity("东莞", "广东省", "东莞", "101281601", "dongguan");
        addCity("中山", "广东省", "中山", "101281701", "zhongshan");
        addCity("阳江", "广东省", "阳江", "101281801", "yangjiang");
        addCity("揭阳", "广东省", "揭阳", "101281901", "jieyang");
        addCity("茂名", "广东省", "茂名", "101282001", "maoming");
        addCity("汕尾", "广东省", "汕尾", "101282101", "shanwei");

        // ===== 广西 =====
        addCity("南宁", "广西", "南宁", "101300101", "nanning");
        addCity("柳州", "广西", "柳州", "101300301", "liuzhou");
        addCity("桂林", "广西", "桂林", "101300501", "guilin");
        addCity("梧州", "广西", "梧州", "101300601", "wuzhou");
        addCity("玉林", "广西", "玉林", "101300901", "yulin");
        addCity("百色", "广西", "百色", "101301001", "baise");
        addCity("钦州", "广西", "钦州", "101300701", "qinzhou");
        addCity("河池", "广西", "河池", "101301101", "hechi");
        addCity("北海", "广西", "北海", "101301301", "beihai");
        addCity("崇左", "广西", "崇左", "101300201", "chongzuo");
        addCity("来宾", "广西", "来宾", "101300401", "laibin");
        addCity("贺州", "广西", "贺州", "101300801", "hezhou");
        addCity("防城港", "广西", "防城港", "101301401", "fangchenggang");
        addCity("贵港", "广西", "贵港", "101301201", "guigang");

        // ===== 海南省 =====
        addCity("海口", "海南省", "海口", "101310101", "haikou");
        addCity("三亚", "海南省", "三亚", "101310201", "sanya");
        addCity("三沙", "海南省", "三沙", "101310301", "sansha");
        addCity("儋州", "海南省", "儋州", "101310401", "danzhou");

        // ===== 四川省 =====
        addCity("成都", "四川省", "成都", "101270101", "chengdu");
        addCity("攀枝花", "四川省", "攀枝花", "101270201", "panzhihua");
        addCity("自贡", "四川省", "自贡", "101270301", "zigong");
        addCity("绵阳", "四川省", "绵阳", "101270401", "mianyang");
        addCity("南充", "四川省", "南充", "101270801", "nanchong");
        addCity("达州", "四川省", "达州", "101270501", "dazhou");
        addCity("遂宁", "四川省", "遂宁", "101270701", "suining");
        addCity("广安", "四川省", "广安", "101271601", "guangan");
        addCity("巴中", "四川省", "巴中", "101270901", "bazhong");
        addCity("泸州", "四川省", "泸州", "101271001", "luzhou");
        addCity("宜宾", "四川省", "宜宾", "101271201", "yibin");
        addCity("内江", "四川省", "内江", "101271101", "neijiang");
        addCity("资阳", "四川省", "资阳", "101271901", "ziyang");
        addCity("乐山", "四川省", "乐山", "101271401", "leshan");
        addCity("眉山", "四川省", "眉山", "101271701", "meishan");
        addCity("雅安", "四川省", "雅安", "101271501", "yaan");
        addCity("德阳", "四川省", "德阳", "101272001", "deyang");
        addCity("广元", "四川省", "广元", "101272101", "guangyuan");
        addCity("阿坝", "四川省", "阿坝", "101272201", "aba");
        addCity("甘孜", "四川省", "甘孜", "101272301", "ganzi");
        addCity("凉山", "四川省", "凉山", "101271301", "liangshan");

        // ===== 贵州省 =====
        addCity("贵阳", "贵州省", "贵阳", "101260101", "guiyang");
        addCity("遵义", "贵州省", "遵义", "101260201", "zunyi");
        addCity("安顺", "贵州省", "安顺", "101260301", "anshun");
        addCity("毕节", "贵州省", "毕节", "101260801", "bijie");
        addCity("铜仁", "贵州省", "铜仁", "101260601", "tongren");
        addCity("六盘水", "贵州省", "六盘水", "101260701", "liupanshui");
        addCity("黔东南", "贵州省", "黔东南", "101260401", "qiandongnan");
        addCity("黔南", "贵州省", "黔南", "101260501", "qiannan");
        addCity("黔西南", "贵州省", "黔西南", "101260901", "qianxinan");

        // ===== 云南省 =====
        addCity("昆明", "云南省", "昆明", "101290101", "kunming");
        addCity("曲靖", "云南省", "曲靖", "101290201", "qujing");
        addCity("玉溪", "云南省", "玉溪", "101290301", "yuxi");
        addCity("保山", "云南省", "保山", "101290501", "baoshan");
        addCity("昭通", "云南省", "昭通", "101290601", "zhaotong");
        addCity("丽江", "云南省", "丽江", "101290701", "lijiang");
        addCity("普洱", "云南省", "普洱", "101290801", "puer");
        addCity("临沧", "云南省", "临沧", "101290901", "lincang");
        addCity("楚雄", "云南省", "楚雄", "101291001", "chuxiong");
        addCity("红河", "云南省", "红河", "101291101", "honghe");
        addCity("文山", "云南省", "文山", "101291201", "wenshan");
        addCity("西双版纳", "云南省", "西双版纳", "101291301", "xishuangbanna");
        addCity("大理", "云南省", "大理", "101291401", "dali");
        addCity("德宏", "云南省", "德宏", "101291501", "dehong");
        addCity("怒江", "云南省", "怒江", "101291601", "nujiang");
        addCity("迪庆", "云南省", "迪庆", "101291701", "diqing");

        // ===== 西藏 =====
        addCity("拉萨", "西藏", "拉萨", "101140101", "lasa");
        addCity("日喀则", "西藏", "日喀则", "101140201", "rikaze");
        addCity("昌都", "西藏", "昌都", "101140501", "changdu");
        addCity("林芝", "西藏", "林芝", "101140601", "linzhi");
        addCity("山南", "西藏", "山南", "101140301", "shannan");
        addCity("那曲", "西藏", "那曲", "101140701", "naqu");
        addCity("阿里", "西藏", "阿里", "101140801", "ali");

        // ===== 陕西省 =====
        addCity("西安", "陕西省", "西安", "101110101", "xian");
        addCity("铜川", "陕西省", "铜川", "101110201", "tongchuan");
        addCity("宝鸡", "陕西省", "宝鸡", "101110301", "baoji");
        addCity("咸阳", "陕西省", "咸阳", "101110401", "xianyang");
        addCity("渭南", "陕西省", "渭南", "101110501", "weinan");
        addCity("延安", "陕西省", "延安", "101110601", "yanan");
        addCity("汉中", "陕西省", "汉中", "101110701", "hanzhong");
        addCity("榆林", "陕西省", "榆林", "101110801", "yulin");
        addCity("安康", "陕西省", "安康", "101110901", "ankang");
        addCity("商洛", "陕西省", "商洛", "101111001", "shangluo");

        // ===== 甘肃省 =====
        addCity("兰州", "甘肃省", "兰州", "101160101", "lanzhou");
        addCity("嘉峪关", "甘肃省", "嘉峪关", "101160201", "jiayuguan");
        addCity("金昌", "甘肃省", "金昌", "101160301", "jinchang");
        addCity("白银", "甘肃省", "白银", "101160401", "baiyin");
        addCity("天水", "甘肃省", "天水", "101160501", "tianshui");
        addCity("武威", "甘肃省", "武威", "101160601", "wuwei");
        addCity("张掖", "甘肃省", "张掖", "101160701", "zhangye");
        addCity("平凉", "甘肃省", "平凉", "101160801", "pingliang");
        addCity("酒泉", "甘肃省", "酒泉", "101160901", "jiuquan");
        addCity("庆阳", "甘肃省", "庆阳", "101161001", "qingyang");
        addCity("定西", "甘肃省", "定西", "101161101", "dingxi");
        addCity("陇南", "甘肃省", "陇南", "101161201", "longnan");
        addCity("临夏", "甘肃省", "临夏", "101161301", "linxia");
        addCity("甘南", "甘肃省", "甘南", "101161401", "gannan");

        // ===== 青海省 =====
        addCity("西宁", "青海省", "西宁", "101150101", "xining");
        addCity("海东", "青海省", "海东", "101150201", "haidong");
        addCity("海北", "青海省", "海北", "101150301", "haibei");
        addCity("黄南", "青海省", "黄南", "101150401", "huangnan");
        addCity("海南", "青海省", "海南", "101150501", "hainan");
        addCity("果洛", "青海省", "果洛", "101150601", "guoluo");
        addCity("玉树", "青海省", "玉树", "101150701", "yushu");
        addCity("海西", "青海省", "海西", "101150801", "haixi");

        // ===== 宁夏 =====
        addCity("银川", "宁夏", "银川", "101170101", "yinchuan");
        addCity("石嘴山", "宁夏", "石嘴山", "101170201", "shizuishan");
        addCity("吴忠", "宁夏", "吴忠", "101170301", "wuzhong");
        addCity("固原", "宁夏", "固原", "101170401", "guyuan");
        addCity("中卫", "宁夏", "中卫", "101170501", "zhongwei");

        // ===== 新疆 =====
        addCity("乌鲁木齐", "新疆", "乌鲁木齐", "101130101", "wulumuqi");
        addCity("克拉玛依", "新疆", "克拉玛依", "101130201", "kelamayi");
        addCity("吐鲁番", "新疆", "吐鲁番", "101130401", "tulufan");
        addCity("哈密", "新疆", "哈密", "101130501", "hami");
        addCity("昌吉", "新疆", "昌吉", "101130301", "changji");
        addCity("博尔塔拉", "新疆", "博尔塔拉", "101130601", "boertala");
        addCity("巴音郭楞", "新疆", "巴音郭楞", "101130701", "bayinguoleng");
        addCity("阿克苏", "新疆", "阿克苏", "101130801", "akesu");
        addCity("克州", "新疆", "克州", "101130901", "kezhou");
        addCity("喀什", "新疆", "喀什", "101131001", "kashi");
        addCity("和田", "新疆", "和田", "101131101", "hetian");
        addCity("伊犁", "新疆", "伊犁", "101131201", "yili");
        addCity("塔城", "新疆", "塔城", "101131301", "tacheng");
        addCity("阿勒泰", "新疆", "阿勒泰", "101131401", "aletai");

        // ===== 香港/澳门 =====
        addCity("香港", "香港", "香港", "101320101", "xianggang");
        addCity("澳门", "澳门", "澳门", "101330101", "aomen");

        // ===== 台湾 =====
        addCity("台北", "台湾", "台北", "101340101", "taibei");
        addCity("高雄", "台湾", "高雄", "101340201", "gaoxiong");
        addCity("台中", "台湾", "台中", "101340401", "taizhong");
        addCity("台南", "台湾", "台南", "101340501", "tainan");
        addCity("新竹", "台湾", "新竹", "101340601", "xinzhú");
        addCity("嘉义", "台湾", "嘉义", "101340701", "jiayi");
    }

    private static void addCity(String name, String adm1, String adm2, String id, String pinyin) {
        CityInfo city = new CityInfo();
        city.setName(name);
        city.setAdm1(adm1);
        city.setAdm2(adm2);
        city.setId(id);
        city.setPinyin(pinyin);
        CITIES.add(city);
    }

    /**
     * 根据关键词模糊搜索城市（支持中文和拼音）
     * @param keyword 搜索关键词（中文或拼音）
     * @return 匹配的城市列表
     */
    public static List<CityInfo> searchCities(String keyword) {
        List<CityInfo> results = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) {
            return results;
        }

        String trimmedKeyword = keyword.trim().toLowerCase();

        for (CityInfo city : CITIES) {
            String name = city.getName();
            String adm1 = city.getAdm1();
            String adm2 = city.getAdm2();
            String pinyin = city.getPinyin();

            // 模糊匹配：城市名、省级、市级、拼音包含关键词
            if (name.contains(trimmedKeyword) ||
                adm1.contains(trimmedKeyword) ||
                adm2.contains(trimmedKeyword) ||
                (pinyin != null && pinyin.contains(trimmedKeyword))) {
                results.add(city);
            }
        }

        return results;
    }

    /**
     * 获取所有城市
     */
    public static List<CityInfo> getAllCities() {
        return new ArrayList<>(CITIES);
    }
}
