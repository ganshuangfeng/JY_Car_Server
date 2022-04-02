/*
 Navicat Premium Data Transfer

 Source Server         : ★★★★★aliyun_release★★★★★
 Source Server Type    : MySQL
 Source Server Version : 50723
 Source Host           : 172.18.107.235:2356
 Source Schema         : jygame

 Target Server Type    : MySQL
 Target Server Version : 50723
 File Encoding         : 65001

 Date: 13/03/2020 15:58:18
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for act_new_spec_lottery_award_log
-- ----------------------------
DROP TABLE IF EXISTS `act_new_spec_lottery_award_log`;
CREATE TABLE `act_new_spec_lottery_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `game_num` smallint(20) NULL DEFAULT NULL COMMENT '第几次游戏(摇色子)',
  `award_id` smallint(20) NULL DEFAULT NULL COMMENT '要中的奖励id',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 209383 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for act_new_spec_lottery_data
-- ----------------------------
DROP TABLE IF EXISTS `act_new_spec_lottery_data`;
CREATE TABLE `act_new_spec_lottery_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `now_game_profit_acc` int(50) NULL DEFAULT NULL COMMENT '当前的游戏累积赢金',
  `now_buyu_game_profit_acc` int(50) NULL DEFAULT 0 COMMENT '当前的捕鱼游戏累积赢金',
  `now_charge_profit_acc` mediumint(30) NULL DEFAULT NULL COMMENT '当前的充值累积',
  `now_credits` mediumint(30) NULL DEFAULT NULL COMMENT '当前的积分数量',
  `now_game_num` smallint(20) NULL DEFAULT NULL COMMENT '当前游戏了多少次，摇了多少次色子',
  `have_get_award_num` smallint(20) NULL DEFAULT 0 COMMENT '奖励领取的状态数字',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for act_old_spec_lottery_award_log
-- ----------------------------
DROP TABLE IF EXISTS `act_old_spec_lottery_award_log`;
CREATE TABLE `act_old_spec_lottery_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `game_num` smallint(20) NULL DEFAULT NULL COMMENT '第几次游戏(摇色子)',
  `award_id` smallint(20) NULL DEFAULT NULL COMMENT '要中的奖励id',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9631 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for act_old_spec_lottery_data
-- ----------------------------
DROP TABLE IF EXISTS `act_old_spec_lottery_data`;
CREATE TABLE `act_old_spec_lottery_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `player_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家名称',
  `now_game_profit_acc` int(50) NULL DEFAULT NULL COMMENT '当前的游戏累积赢金',
  `now_charge_profit_acc` mediumint(30) NULL DEFAULT NULL COMMENT '当前的充值累积',
  `now_credits` mediumint(30) NULL DEFAULT NULL COMMENT '当前的积分数量',
  `now_game_num` smallint(20) NULL DEFAULT NULL COMMENT '当前游戏了多少次，摇了多少次色子',
  `have_get_award_num` smallint(20) NULL DEFAULT 0 COMMENT '奖励领取的状态数字',
  `total_credits` int(50) NULL DEFAULT NULL COMMENT '累积积分',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for activity_cumulate_data
-- ----------------------------
DROP TABLE IF EXISTS `activity_cumulate_data`;
CREATE TABLE `activity_cumulate_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `game_id` mediumint(20) NULL DEFAULT NULL COMMENT '自由场id',
  `progress` mediumint(20) NULL DEFAULT NULL COMMENT '进度',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '操作时间',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for admin_decrease_asset_log
-- ----------------------------
DROP TABLE IF EXISTS `admin_decrease_asset_log`;
CREATE TABLE `admin_decrease_asset_log`  (
  `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志 id ，主键',
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `asset_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '财物类型： match_ticket, room_card,shop_gold,cash',
  `current` bigint(20) NULL DEFAULT NULL COMMENT '变化后数量',
  `change_value` bigint(20) NULL DEFAULT NULL COMMENT '变化量',
  `date` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  `opt_admin` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作人',
  `reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '原因',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `index2`(`asset_type`) USING BTREE,
  INDEX `index3`(`opt_admin`) USING BTREE,
  INDEX `index4`(`reason`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 255 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for admin_op_log
-- ----------------------------
DROP TABLE IF EXISTS `admin_op_log`;
CREATE TABLE `admin_op_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '管理员id',
  `op_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `player_id1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '被操作的相关玩家1',
  `player_id2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '被操作的相关玩家2',
  `op_data1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '操作的数据1',
  `op_data2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '操作的数据2',
  `op_data3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '操作的数据3',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 336 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '管理员操作日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for alipay_account_statistic
-- ----------------------------
DROP TABLE IF EXISTS `alipay_account_statistic`;
CREATE TABLE `alipay_account_statistic`  (
  `alipay_account` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `platform` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `num` tinyint(50) NULL DEFAULT 0,
  UNIQUE INDEX `1`(`alipay_account`, `platform`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for auto_bet_player
-- ----------------------------
DROP TABLE IF EXISTS `auto_bet_player`;
CREATE TABLE `auto_bet_player`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家Id',
  `fish_1` int(50) UNSIGNED ZEROFILL NULL DEFAULT NULL COMMENT '鱼道1',
  `fish_2` int(50) NULL DEFAULT NULL,
  `fish_3` int(50) NULL DEFAULT NULL,
  `fish_4` int(50) NULL DEFAULT NULL,
  `fish_5` int(50) NULL DEFAULT NULL,
  `fish_6` int(50) NULL DEFAULT NULL,
  `fish_7` int(50) NULL DEFAULT NULL,
  `all_bet` int(255) NULL DEFAULT NULL,
  `reward` int(255) NULL DEFAULT NULL,
  `total_frequency` smallint(50) NULL DEFAULT NULL COMMENT '总挂机次数',
  `current_frequency` smallint(50) NULL DEFAULT NULL COMMENT '当前挂机次数',
  `fish_num_1` smallint(50) NULL DEFAULT NULL COMMENT '获得1道的鱼数',
  `fish_num_2` smallint(50) NULL DEFAULT NULL,
  `fish_num_3` smallint(50) NULL DEFAULT NULL,
  `fish_num_4` smallint(50) NULL DEFAULT NULL,
  `fish_num_5` smallint(50) NULL DEFAULT NULL,
  `fish_num_6` smallint(50) NULL DEFAULT NULL,
  `fish_num_7` smallint(50) NULL DEFAULT NULL,
  `accomplish` tinyint(50) NULL DEFAULT NULL COMMENT '是否到达挂机次数',
  `ingots` smallint(50) NULL DEFAULT NULL COMMENT '元宝次数',
  `fish_total_num` smallint(255) NULL DEFAULT NULL COMMENT '总共捕获鱼数',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bind_phone_number
-- ----------------------------
DROP TABLE IF EXISTS `bind_phone_number`;
CREATE TABLE `bind_phone_number`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `phone_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '绑定电话号码',
  `bind_time` datetime(0) NULL DEFAULT NULL COMMENT '绑定时间',
  PRIMARY KEY (`player_id`) USING BTREE,
  INDEX `phone_number`(`phone_number`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bind_phone_number_opt_log
-- ----------------------------
DROP TABLE IF EXISTS `bind_phone_number_opt_log`;
CREATE TABLE `bind_phone_number_opt_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `old_phone_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `new_phone_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `opt_time` datetime(0) NULL DEFAULT NULL,
  `opt_admin` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cai_dengmi_info
-- ----------------------------
DROP TABLE IF EXISTS `cai_dengmi_info`;
CREATE TABLE `cai_dengmi_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `is_true` tinyint(4) NULL DEFAULT NULL COMMENT '0没答，1答错，2答对',
  `time_count` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '时间_次数',
  `share_time` datetime(0) NULL DEFAULT NULL COMMENT '分享时间',
  `guess_time` datetime(0) NULL DEFAULT NULL COMMENT '答题时间',
  `award_time` datetime(0) NULL DEFAULT NULL COMMENT '领奖时间',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cai_dengmi_log
-- ----------------------------
DROP TABLE IF EXISTS `cai_dengmi_log`;
CREATE TABLE `cai_dengmi_log`  (
  `id` bigint(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 121597 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cjs_divide_jingbi_award_log
-- ----------------------------
DROP TABLE IF EXISTS `cjs_divide_jingbi_award_log`;
CREATE TABLE `cjs_divide_jingbi_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `player_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家昵称',
  `task_id` int(50) NULL DEFAULT NULL COMMENT '任务id',
  `award_value` int(255) NULL DEFAULT NULL COMMENT '奖励值',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 417 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for click_like_act_status
-- ----------------------------
DROP TABLE IF EXISTS `click_like_act_status`;
CREATE TABLE `click_like_act_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `by_num` tinyint(10) NULL DEFAULT NULL COMMENT '捕鱼点赞数',
  `sh_num` tinyint(10) NULL DEFAULT NULL COMMENT '水浒点赞数',
  `sg_num` tinyint(10) NULL DEFAULT NULL COMMENT '水果点赞数',
  `qql_num` tinyint(10) NULL DEFAULT NULL COMMENT '敲敲乐点赞数',
  `box_status` tinyint(10) NULL DEFAULT NULL COMMENT '领取状态，0没领，1可领，2领过了',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for click_like_advise
-- ----------------------------
DROP TABLE IF EXISTS `click_like_advise`;
CREATE TABLE `click_like_advise`  (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT '建议id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `advise` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '建议内容json',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 145 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for click_like_info
-- ----------------------------
DROP TABLE IF EXISTS `click_like_info`;
CREATE TABLE `click_like_info`  (
  `game_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '游戏类型',
  `num` int(10) NULL DEFAULT NULL COMMENT '点赞数量',
  PRIMARY KEY (`game_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for click_like_log
-- ----------------------------
DROP TABLE IF EXISTS `click_like_log`;
CREATE TABLE `click_like_log`  (
  `id` bigint(255) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '动作',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10156 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for club_info
-- ----------------------------
DROP TABLE IF EXISTS `club_info`;
CREATE TABLE `club_info`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户id',
  `parent_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '上级玩家id',
  `parent_ids` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '祖先id链，json 字符串',
  `is_tgy` int(11) NULL DEFAULT 0 COMMENT '是否推广员。 1 是； 0 否。',
  `is_agent` int(11) NULL DEFAULT 0 COMMENT '是否代理。 1 是； 0 否。',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '俱乐部 ，或者叫：分销系统/牌友圈/推广系统' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for common_lottery_award_log
-- ----------------------------
DROP TABLE IF EXISTS `common_lottery_award_log`;
CREATE TABLE `common_lottery_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `lottery_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '抽奖类型',
  `game_num` smallint(20) NULL DEFAULT NULL COMMENT '第几次游戏(摇色子)',
  `award_id` smallint(20) NULL DEFAULT NULL COMMENT '要中的奖励id',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `spend_ticket_num` int(50) NULL DEFAULT NULL COMMENT '消耗的抽奖券',
  `is_shiwu` tinyint(10) NULL DEFAULT 0 COMMENT '是否是实物(0 不是 1是 , 默认是0)',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 191766 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for common_lottery_base_data
-- ----------------------------
DROP TABLE IF EXISTS `common_lottery_base_data`;
CREATE TABLE `common_lottery_base_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `lottery_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '抽奖类型',
  `ticket_num` int(50) NULL DEFAULT NULL COMMENT '当前抽奖券个数',
  `total_ticket_log_num` int(50) NULL DEFAULT NULL COMMENT '总共的历史上获得了多少抽奖券',
  `now_game_num` smallint(30) NULL DEFAULT NULL COMMENT '当前的抽奖次数',
  `have_get_award_status_num` int(50) NULL DEFAULT NULL COMMENT '获得的奖励id的状态数值',
  `last_lottery_time` bigint(50) NULL DEFAULT 0 COMMENT '上次抽奖的时间',
  PRIMARY KEY (`player_id`, `lottery_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for common_lottery_player_lottery_limit
-- ----------------------------
DROP TABLE IF EXISTS `common_lottery_player_lottery_limit`;
CREATE TABLE `common_lottery_player_lottery_limit`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `lottery_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '抽奖类型',
  `round_id` smallint(20) NOT NULL COMMENT '抽奖的轮次id',
  `now_lottery_num` int(50) NULL DEFAULT NULL COMMENT '当前抽奖次数',
  `last_lottery_time` bigint(50) NULL DEFAULT NULL COMMENT '上次抽奖时间',
  PRIMARY KEY (`player_id`, `lottery_type`, `round_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for common_lottery_round_lottery_limit
-- ----------------------------
DROP TABLE IF EXISTS `common_lottery_round_lottery_limit`;
CREATE TABLE `common_lottery_round_lottery_limit`  (
  `lottery_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '抽奖类型',
  `lottery_round_id` smallint(30) NOT NULL COMMENT '抽奖轮次',
  `now_total_lottery_num` int(50) NULL DEFAULT NULL COMMENT '当前抽奖的次数',
  `last_lottery_time` bigint(50) NULL DEFAULT NULL COMMENT '上次抽的时间',
  PRIMARY KEY (`lottery_type`, `lottery_round_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for common_lottery_score_data
-- ----------------------------
DROP TABLE IF EXISTS `common_lottery_score_data`;
CREATE TABLE `common_lottery_score_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `lottery_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '抽奖类型',
  `score_pool_id` int(50) NOT NULL COMMENT '分数池id,转换抽奖券规则id',
  `score` int(50) NULL DEFAULT NULL COMMENT '分数',
  PRIMARY KEY (`player_id`, `lottery_type`, `score_pool_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for common_question_answer_add_num_log
-- ----------------------------
DROP TABLE IF EXISTS `common_question_answer_add_num_log`;
CREATE TABLE `common_question_answer_add_num_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `act_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '活动key',
  `add_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '增加次数的类型',
  `add_value` smallint(30) NULL DEFAULT NULL COMMENT '增加次数',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30178 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for common_question_answer_data
-- ----------------------------
DROP TABLE IF EXISTS `common_question_answer_data`;
CREATE TABLE `common_question_answer_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `act_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '活动key',
  `now_answer_num` smallint(30) NULL DEFAULT NULL COMMENT '当前的答题次数',
  `now_add_answer_num` smallint(30) NULL DEFAULT NULL COMMENT '当前已经增加了多少次回答次数',
  `last_answer_time` bigint(50) NULL DEFAULT NULL COMMENT '上次答题时间',
  PRIMARY KEY (`player_id`, `act_key`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for common_question_answer_topic_log
-- ----------------------------
DROP TABLE IF EXISTS `common_question_answer_topic_log`;
CREATE TABLE `common_question_answer_topic_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `test_id` int(50) NULL DEFAULT NULL COMMENT '测试id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `act_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '活动key',
  `topic_id` int(50) NULL DEFAULT NULL COMMENT '题目id',
  `answer_id` smallint(30) NULL DEFAULT NULL COMMENT '本次回答的id',
  `is_right` tinyint(10) NULL DEFAULT NULL COMMENT '是否正确， 1是正确，0是错误',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 64309 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_juju_data
-- ----------------------------
DROP TABLE IF EXISTS `cpl_juju_data`;
CREATE TABLE `cpl_juju_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_juxiang_data
-- ----------------------------
DROP TABLE IF EXISTS `cpl_juxiang_data`;
CREATE TABLE `cpl_juxiang_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_pceggs_data
-- ----------------------------
DROP TABLE IF EXISTS `cpl_pceggs_data`;
CREATE TABLE `cpl_pceggs_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_pceggs_data_p10_all_20200207
-- ----------------------------
DROP TABLE IF EXISTS `cpl_pceggs_data_p10_all_20200207`;
CREATE TABLE `cpl_pceggs_data_p10_all_20200207`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_pceggs_data_p11_all_20200306
-- ----------------------------
DROP TABLE IF EXISTS `cpl_pceggs_data_p11_all_20200306`;
CREATE TABLE `cpl_pceggs_data_p11_all_20200306`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_pceggs_data_p8_and_20200108
-- ----------------------------
DROP TABLE IF EXISTS `cpl_pceggs_data_p8_and_20200108`;
CREATE TABLE `cpl_pceggs_data_p8_and_20200108`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_pceggs_data_p8_and_20200108_2
-- ----------------------------
DROP TABLE IF EXISTS `cpl_pceggs_data_p8_and_20200108_2`;
CREATE TABLE `cpl_pceggs_data_p8_and_20200108_2`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_pceggs_data_p9_and_20200116
-- ----------------------------
DROP TABLE IF EXISTS `cpl_pceggs_data_p9_and_20200116`;
CREATE TABLE `cpl_pceggs_data_p9_and_20200116`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_qwxq_data
-- ----------------------------
DROP TABLE IF EXISTS `cpl_qwxq_data`;
CREATE TABLE `cpl_qwxq_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_qwxq_data_p1
-- ----------------------------
DROP TABLE IF EXISTS `cpl_qwxq_data_p1`;
CREATE TABLE `cpl_qwxq_data_p1`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_var_change_log
-- ----------------------------
DROP TABLE IF EXISTS `cpl_var_change_log`;
CREATE TABLE `cpl_var_change_log`  (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `cpl_channel` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'cpl渠道',
  `var_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '变量名',
  `var_value_prev` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '改变前的值',
  `var_value_after` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '改变后的值',
  `change_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `cpl_channel`(`cpl_channel`) USING BTREE,
  INDEX `player_id`(`player_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'cpl变量手工修改日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xianwan_clby_data
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xianwan_clby_data`;
CREATE TABLE `cpl_xianwan_clby_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xianwan_clby_p2_all_20200207
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xianwan_clby_p2_all_20200207`;
CREATE TABLE `cpl_xianwan_clby_p2_all_20200207`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xianwan_clby_p3_all_20200306
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xianwan_clby_p3_all_20200306`;
CREATE TABLE `cpl_xianwan_clby_p3_all_20200306`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xianwan_data
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xianwan_data`;
CREATE TABLE `cpl_xianwan_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xianwan_data_p10_all_20200207
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xianwan_data_p10_all_20200207`;
CREATE TABLE `cpl_xianwan_data_p10_all_20200207`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xianwan_data_p11_all_20200306
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xianwan_data_p11_all_20200306`;
CREATE TABLE `cpl_xianwan_data_p11_all_20200306`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xianwan_data_p8_and_20200108
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xianwan_data_p8_and_20200108`;
CREATE TABLE `cpl_xianwan_data_p8_and_20200108`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xianwan_data_p9_ios_20200117
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xianwan_data_p9_ios_20200117`;
CREATE TABLE `cpl_xianwan_data_p9_ios_20200117`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xiaozhuo_data
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xiaozhuo_data`;
CREATE TABLE `cpl_xiaozhuo_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cpl_xiaozhuo_data_p1
-- ----------------------------
DROP TABLE IF EXISTS `cpl_xiaozhuo_data_p1`;
CREATE TABLE `cpl_xiaozhuo_data_p1`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `payment` int(255) NULL DEFAULT 0 COMMENT '充值，人民币，分',
  `win_jingbi` bigint(255) NULL DEFAULT 0 COMMENT '累积赢鲸币',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `old_player` int(255) NULL DEFAULT NULL COMMENT '老用户：0或null  本期， 1 上一期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for data_test
-- ----------------------------
DROP TABLE IF EXISTS `data_test`;
CREATE TABLE `data_test`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `f1` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `f2` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dwq_cdkey
-- ----------------------------
DROP TABLE IF EXISTS `dwq_cdkey`;
CREATE TABLE `dwq_cdkey`  (
  `no` bigint(20) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `asset_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `cdkey` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`no`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dwq_cdkey_use_log
-- ----------------------------
DROP TABLE IF EXISTS `dwq_cdkey_use_log`;
CREATE TABLE `dwq_cdkey_use_log`  (
  `no` bigint(20) NULL DEFAULT NULL,
  `use_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `owner_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `asset_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `cdkey` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `use_type` int(11) NULL DEFAULT NULL,
  `use_time` datetime(0) NULL DEFAULT NULL,
  `create_time` datetime(0) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dwq_use_log
-- ----------------------------
DROP TABLE IF EXISTS `dwq_use_log`;
CREATE TABLE `dwq_use_log`  (
  `no` bigint(20) NULL DEFAULT NULL,
  `use_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `owner_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `asset_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `cdkey` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `use_type` int(11) NULL DEFAULT NULL,
  `use_time` datetime(0) NULL DEFAULT NULL,
  `create_time` datetime(0) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for emails
-- ----------------------------
DROP TABLE IF EXISTS `emails`;
CREATE TABLE `emails`  (
  `id` int(50) UNSIGNED NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `sender` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `receiver` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `valid_time` bigint(20) NULL DEFAULT NULL,
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `create_time` bigint(20) NULL DEFAULT NULL,
  `complete_time` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `1`(`receiver`) USING BTREE COMMENT 'select'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for emails_admin_opt_log
-- ----------------------------
DROP TABLE IF EXISTS `emails_admin_opt_log`;
CREATE TABLE `emails_admin_opt_log`  (
  `id` int(50) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id\n\n10111111111，ID由11位数字组成，前两位表示服务器号',
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `time` datetime(6) NULL DEFAULT NULL,
  `opt_admin` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '创建邮件的管理员',
  `reason` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_latvian_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 254733 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for emails_every
-- ----------------------------
DROP TABLE IF EXISTS `emails_every`;
CREATE TABLE `emails_every`  (
  `id` int(50) UNSIGNED NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `sender` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `valid_time` bigint(20) NULL DEFAULT NULL,
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `create_time` datetime(6) NULL DEFAULT NULL COMMENT '这个全服邮件创建的时间',
  `receive_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `receive_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for emails_every_player
-- ----------------------------
DROP TABLE IF EXISTS `emails_every_player`;
CREATE TABLE `emails_every_player`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `last_email_id` int(20) NULL DEFAULT 0 COMMENT '上次已经领取了的全服邮件id',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for emails_log
-- ----------------------------
DROP TABLE IF EXISTS `emails_log`;
CREATE TABLE `emails_log`  (
  `id` int(50) NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `sender` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `receiver` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `valid_time` datetime(6) NULL DEFAULT NULL,
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `create_time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for emails_opt_log
-- ----------------------------
DROP TABLE IF EXISTS `emails_opt_log`;
CREATE TABLE `emails_opt_log`  (
  `id` int(50) UNSIGNED NOT NULL AUTO_INCREMENT,
  `email_id` int(255) NULL DEFAULT NULL,
  `opt` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12738365 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for exec_sql_info
-- ----------------------------
DROP TABLE IF EXISTS `exec_sql_info`;
CREATE TABLE `exec_sql_info`  (
  `proc_id` int(11) NOT NULL COMMENT '进程id',
  `statement_index` int(11) NOT NULL COMMENT '语句序号',
  `dur` double NOT NULL COMMENT '语句消耗的时间',
  PRIMARY KEY (`proc_id`, `statement_index`) USING HASH,
  INDEX `dur`(`dur`) USING HASH,
  INDEX `proc_id`(`proc_id`) USING HASH
) ENGINE = MEMORY CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Fixed;

-- ----------------------------
-- Table structure for exec_sql_info_batch
-- ----------------------------
DROP TABLE IF EXISTS `exec_sql_info_batch`;
CREATE TABLE `exec_sql_info_batch`  (
  `batch_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '批次号',
  `proc_id` int(11) NOT NULL COMMENT '进程id',
  `batch_dur` double NOT NULL COMMENT '本批次消耗的总时间',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`batch_id`) USING HASH
) ENGINE = MEMORY AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Fixed;

-- ----------------------------
-- Table structure for exec_sql_info_log
-- ----------------------------
DROP TABLE IF EXISTS `exec_sql_info_log`;
CREATE TABLE `exec_sql_info_log`  (
  `batch_id` int(11) NOT NULL AUTO_INCREMENT,
  `statement_index` int(11) NOT NULL COMMENT '语句序号',
  `dur` double NOT NULL COMMENT '语句消耗的时间',
  PRIMARY KEY (`batch_id`, `statement_index`) USING HASH
) ENGINE = MEMORY AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Fixed;

-- ----------------------------
-- Table structure for fish_game_player_data
-- ----------------------------
DROP TABLE IF EXISTS `fish_game_player_data`;
CREATE TABLE `fish_game_player_data`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` tinyint(4) NOT NULL,
  `laser_data` double(11, 2) NULL DEFAULT 0.00 COMMENT '激光值',
  `real_all_fj` double(11, 2) NULL DEFAULT 0.00 COMMENT '真实总返奖',
  `real_laser_bc` double(11, 2) NULL DEFAULT 0.00 COMMENT '真实激光补偿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `key`(`player_id`, `game_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4251770 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for fish_game_player_reward_data
-- ----------------------------
DROP TABLE IF EXISTS `fish_game_player_reward_data`;
CREATE TABLE `fish_game_player_reward_data`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` tinyint(4) NOT NULL,
  `pao_lv` tinyint(4) NOT NULL,
  `all_fj` double(11, 2) NULL DEFAULT 0.00 COMMENT '总返奖',
  `store_fj` double(11, 2) NULL DEFAULT 0.00 COMMENT '存储返奖',
  `xyBuDy_fj` double(11, 2) NULL DEFAULT 0.00 COMMENT '小鱼补大鱼返奖',
  `laser_bc_fj` double(11, 2) NULL DEFAULT 0.00 COMMENT '激光补偿',
  `dayu_fj` double(11, 2) NULL DEFAULT 0.00 COMMENT '大鱼返奖',
  `act_fj` double(11, 2) NULL DEFAULT 0.00 COMMENT '活动返奖',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `key`(`player_id`, `game_id`, `pao_lv`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 35985076 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for fish_game_player_wave_data
-- ----------------------------
DROP TABLE IF EXISTS `fish_game_player_wave_data`;
CREATE TABLE `fish_game_player_wave_data`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` tinyint(4) NOT NULL,
  `bd_type` int(11) NULL DEFAULT 0,
  `pao_lv` tinyint(4) NOT NULL,
  `all_times` double(11, 2) NULL DEFAULT 0.00 COMMENT '总次数',
  `cur_times` double(11, 2) NULL DEFAULT 0.00 COMMENT '当前次数',
  `store_value` double(11, 6) NULL DEFAULT 0.000000 COMMENT '被存储下的值',
  `is_zheng` double(11, 2) NULL DEFAULT 0.00 COMMENT '当前波动是正还是负值',
  `bd_factor` double(11, 6) NULL DEFAULT 0.000000 COMMENT '当前的波动系数',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `key`(`player_id`, `game_id`, `pao_lv`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 35984041 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for fish_game_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `fish_game_race_player_log`;
CREATE TABLE `fish_game_race_player_log`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` int(4) NULL DEFAULT NULL,
  `bullet_assets` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `bullet_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `return_bullet_assets` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `return_bullet_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `fish_dead_assets` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `fish_dead_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fgrpl_game_id_index`(`game_id`) USING BTREE,
  INDEX `fgrpl_time_index`(`time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23115088 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_activity_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_activity_log`;
CREATE TABLE `freestyle_activity_log`  (
  `id` int(10) UNSIGNED NOT NULL,
  `game_id` int(11) NULL DEFAULT NULL,
  `activity_id` int(11) NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `activity_data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '本次活动记录的数据',
  `start_time` datetime(0) NULL DEFAULT NULL,
  `begin_time` datetime(0) NULL DEFAULT NULL,
  `end_time` datetime(0) NULL DEFAULT NULL,
  `over_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_activity_player_data
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_activity_player_data`;
CREATE TABLE `freestyle_activity_player_data`  (
  `player_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `game_id` int(11) NOT NULL,
  `activity_id` int(11) NOT NULL,
  `index` int(4) NOT NULL,
  `data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'lua table',
  PRIMARY KEY (`player_id`, `game_id`, `activity_id`, `index`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_activity_player_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_activity_player_log`;
CREATE TABLE `freestyle_activity_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `game_id` int(10) UNSIGNED NULL DEFAULT NULL,
  `activity_id` int(11) NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `activity_data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '活动数据JSON',
  `award` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2080736 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_hb_game_data
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_hb_game_data`;
CREATE TABLE `freestyle_hb_game_data`  (
  `game_id` int(255) NOT NULL COMMENT '游戏id',
  `award_value` bigint(255) NULL DEFAULT NULL COMMENT '该场次聚宝盆奖励值',
  PRIMARY KEY (`game_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_hb_game_water
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_hb_game_water`;
CREATE TABLE `freestyle_hb_game_water`  (
  `game_id` int(255) NOT NULL COMMENT '游戏id',
  `water` bigint(255) NULL DEFAULT 0 COMMENT '水池，定时清，负数表示系统输',
  `water_total` bigint(255) NULL DEFAULT 0 COMMENT '总水池',
  PRIMARY KEY (`game_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_nmjxl_race_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_nmjxl_race_log`;
CREATE TABLE `freestyle_nmjxl_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_id` int(11) NULL DEFAULT NULL,
  `game_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `gang_count` int(10) NULL DEFAULT 0 COMMENT '杠数量',
  `geng_count` int(10) NULL DEFAULT 0 COMMENT '根',
  `base_score` int(10) NULL DEFAULT 0 COMMENT '底分',
  `operation_list` varbinary(1024) NULL DEFAULT 0 COMMENT '操作序列',
  `zhuang_seat` int(10) NULL DEFAULT 0 COMMENT '庄座位号',
  `seat1_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat2_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat3_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat4_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_nmjxl_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_nmjxl_race_player_log`;
CREATE TABLE `freestyle_nmjxl_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `race_id` int(11) NULL DEFAULT NULL,
  `seat` int(10) NULL DEFAULT 0 COMMENT '座位号',
  `score` int(10) NULL DEFAULT 0 COMMENT '得分',
  `multi` int(10) NULL DEFAULT 0 COMMENT '倍数',
  `gang_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0',
  `pai_info` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_player_everyday_award_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_player_everyday_award_log`;
CREATE TABLE `freestyle_player_everyday_award_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '实例唯一id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '比赛唯一id',
  `award` int(10) UNSIGNED NULL DEFAULT 0,
  `time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 243850 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_player_everyweek_award_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_player_everyweek_award_log`;
CREATE TABLE `freestyle_player_everyweek_award_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '实例唯一id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `week_award` int(10) UNSIGNED NULL DEFAULT 0,
  `week_note` int(10) UNSIGNED NULL DEFAULT 0,
  `time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13268 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_player_today_award
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_player_today_award`;
CREATE TABLE `freestyle_player_today_award`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `today_award` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '比赛唯一id',
  `store_award` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '今天打了几把',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_player_today_race
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_player_today_race`;
CREATE TABLE `freestyle_player_today_race`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '比赛唯一id',
  `today_game_race` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '今天打了几把',
  PRIMARY KEY (`player_id`, `game_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_player_week_award
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_player_week_award`;
CREATE TABLE `freestyle_player_week_award`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `week_race` int(10) UNSIGNED NULL DEFAULT 0,
  `week_target_level` int(10) UNSIGNED NULL DEFAULT 0,
  `get_note` int(10) UNSIGNED NULL DEFAULT 0,
  `last_week_award` int(10) UNSIGNED NULL DEFAULT 0,
  `last_week_my_award` int(10) UNSIGNED NULL DEFAULT 0,
  `last_week_my_note` int(10) UNSIGNED NULL DEFAULT 0,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_race_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_race_log`;
CREATE TABLE `freestyle_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '比赛实例唯一id',
  `game_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '比赛唯一id',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `game_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `player_count` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '参赛人数',
  `races` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `FRL_game_id_index`(`game_id`) USING BTREE,
  INDEX `FRL_begin_time_index`(`begin_time`) USING BTREE,
  INDEX `FRL_game_name_index`(`name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_race_player_log`;
CREATE TABLE `freestyle_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `match_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '比赛实例唯一id',
  `score` bigint(10) NULL DEFAULT 0 COMMENT '成绩',
  `real_score` int(10) NULL DEFAULT 0 COMMENT '真实',
  `room_rent` int(10) NULL DEFAULT 0 COMMENT '真实',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `FRPL_playerid_index`(`player_id`) USING BTREE,
  INDEX `FRPL_matchid_index`(`match_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 129041367 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家比赛日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_tyddz_race_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_tyddz_race_log`;
CREATE TABLE `freestyle_tyddz_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_id` int(10) NULL DEFAULT NULL,
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `bomb_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数量',
  `spring` int(10) NULL DEFAULT 0 COMMENT '春天（0 无，1春天，2 反春）',
  `base_score` int(10) NULL DEFAULT 0 COMMENT '底分',
  `base_rate` int(10) NULL DEFAULT 0 COMMENT '底倍',
  `operation_list` varbinary(500) NULL DEFAULT 0 COMMENT '操作序列',
  `dizhu_seat` int(10) NULL DEFAULT 0 COMMENT '地主座位号',
  `seat1_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat2_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat3_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_tyddz_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_tyddz_race_player_log`;
CREATE TABLE `freestyle_tyddz_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `race_id` int(11) NULL DEFAULT NULL,
  `seat` int(10) NULL DEFAULT 0 COMMENT '座位号',
  `score` int(10) NULL DEFAULT 0 COMMENT '得分',
  `rate` int(10) NULL DEFAULT 0 COMMENT '倍数',
  `bomb_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数（自己的炸弹）',
  `spring` int(10) NULL DEFAULT 0 COMMENT '春天（0 无，1春天，2 反春，3 被春天，4被反春）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_week_award
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_week_award`;
CREATE TABLE `freestyle_week_award`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '实例唯一id',
  `week_show_award` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '总奖金',
  `week_note` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '总注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for freestyle_week_award_log
-- ----------------------------
DROP TABLE IF EXISTS `freestyle_week_award_log`;
CREATE TABLE `freestyle_week_award_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '实例唯一id',
  `week_show_award` bigint(10) UNSIGNED NULL DEFAULT 0 COMMENT '显示的总奖金',
  `week_get_award` bigint(10) NULL DEFAULT NULL COMMENT '真实获得的奖金',
  `week_note` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '总注',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for friendgame_history_record
-- ----------------------------
DROP TABLE IF EXISTS `friendgame_history_record`;
CREATE TABLE `friendgame_history_record`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `game_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `time` bigint(20) NULL DEFAULT 0 COMMENT '得分',
  `room_no` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p1_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p1_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p1_head_img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p1_score` int(20) NULL DEFAULT NULL,
  `p2_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p2_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p2_head_img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p2_score` int(20) NULL DEFAULT NULL,
  `p3_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p3_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p3_head_img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p3_score` int(20) NULL DEFAULT NULL,
  `p4_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p4_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p4_head_img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `p4_score` int(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `time`(`time`) USING BTREE,
  INDEX `p1_id`(`p1_id`) USING BTREE,
  INDEX `p2_id`(`p2_id`) USING BTREE,
  INDEX `p3_id`(`p3_id`) USING BTREE,
  INDEX `p4_id`(`p4_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 304 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for friendgame_player_history
-- ----------------------------
DROP TABLE IF EXISTS `friendgame_player_history`;
CREATE TABLE `friendgame_player_history`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `records` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for friendgame_room_log
-- ----------------------------
DROP TABLE IF EXISTS `friendgame_room_log`;
CREATE TABLE `friendgame_room_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `room_no` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '得分',
  `room_owner` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '房主',
  `room_rent` int(255) NULL DEFAULT NULL COMMENT '房费',
  `room_options` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `over_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for friendgame_room_race_log
-- ----------------------------
DROP TABLE IF EXISTS `friendgame_room_race_log`;
CREATE TABLE `friendgame_room_race_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增长id',
  `room_id` int(11) NULL DEFAULT NULL COMMENT '房间id',
  `race_id` int(11) NULL DEFAULT NULL COMMENT '对局id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `room_id`(`room_id`) USING BTREE,
  INDEX `race_id`(`race_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1934 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '房间对局日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for game_profit
-- ----------------------------
DROP TABLE IF EXISTS `game_profit`;
CREATE TABLE `game_profit`  (
  `game_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '游戏id,matchstyle_xx ; freestyle_xx',
  `total_profit` bigint(50) NULL DEFAULT NULL COMMENT '总共我方收益；(玩家的付出)',
  `total_loss` bigint(50) NULL DEFAULT NULL COMMENT '总共我方付出；(玩家的收益)',
  `total_profit_loss` bigint(50) NULL DEFAULT NULL COMMENT '总共付出or收益',
  `last_record_time` bigint(50) NULL DEFAULT NULL COMMENT '上一次记录的时间',
  `month_profit` bigint(50) NULL DEFAULT NULL COMMENT '当月收益',
  `month_loss` bigint(50) NULL DEFAULT NULL COMMENT '当月付出',
  `month_profit_loss` bigint(50) NULL DEFAULT NULL COMMENT '当月收益or付出',
  `cycle_game_num` int(50) NULL DEFAULT NULL COMMENT '统计周期内的已完成的局数',
  `cycle_profit_loss` int(50) NULL DEFAULT 0 COMMENT '统计周期内的盈亏',
  `cycle_player_num` int(50) NULL DEFAULT 0 COMMENT '统计周期内的参入人次',
  `total_cycle_profit_loss` bigint(50) NULL DEFAULT 0 COMMENT '总共的所有的统计周期的盈亏',
  `total_cycle_player_num` bigint(50) NULL DEFAULT 0 COMMENT '总共的所有的统计周期的参入人次',
  `gain_money_power` int(50) NULL DEFAULT NULL COMMENT '抽水的力度(0~100) %',
  PRIMARY KEY (`game_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for game_profit_cycle_log
-- ----------------------------
DROP TABLE IF EXISTS `game_profit_cycle_log`;
CREATE TABLE `game_profit_cycle_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `game_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '游戏id,matchstyle_xx ; freestyle_xx',
  `cycle_game_num` int(50) NULL DEFAULT NULL COMMENT '这个周期中的游戏局数',
  `cycle_player_num` int(50) NULL DEFAULT NULL COMMENT '这个周期参与人数',
  `cycle_profit_loss` int(50) NULL DEFAULT NULL COMMENT '这个周期的盈利',
  `total_player_num` bigint(50) NULL DEFAULT NULL COMMENT '这个周期结算时的总参与人数',
  `total_profit_loss` bigint(50) NULL DEFAULT NULL COMMENT '这个周期结算时的总盈利',
  `gain_everyone_value` float(50, 2) NULL DEFAULT NULL COMMENT '每人次抽取的个数,cycle_profit_loss / cycle_player_num',
  `wave_trend` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '这个时刻的波形走势，up | down',
  `cycle_gain_power` mediumint(50) NULL DEFAULT NULL COMMENT '这个周期的抽取力度，',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18061235 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for game_profit_statistics
-- ----------------------------
DROP TABLE IF EXISTS `game_profit_statistics`;
CREATE TABLE `game_profit_statistics`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `game_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '游戏id,matchstyle_xx ; freestyle_xx',
  `profit` bigint(50) NULL DEFAULT NULL COMMENT '我方收益',
  `loss` bigint(50) NULL DEFAULT NULL COMMENT '我方付出',
  `profit_loss` bigint(50) NULL DEFAULT NULL COMMENT '收益or付出',
  `record_time` bigint(50) NULL DEFAULT NULL COMMENT '记录的时间',
  `record_year` mediumint(20) NULL DEFAULT NULL COMMENT '记录时的年份',
  `record_month` tinyint(10) NULL DEFAULT NULL COMMENT '记录时的月份',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 511 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for gift_bag_data
-- ----------------------------
DROP TABLE IF EXISTS `gift_bag_data`;
CREATE TABLE `gift_bag_data`  (
  `spcfg_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'shoping_config' COMMENT 'shoping config 的配置名',
  `gift_bag_id` int(4) NOT NULL,
  `gift_bag_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `count` int(20) NULL DEFAULT 0,
  `reset_num` int(10) UNSIGNED NULL DEFAULT 0,
  PRIMARY KEY (`spcfg_name`, `gift_bag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for gift_coupon_data
-- ----------------------------
DROP TABLE IF EXISTS `gift_coupon_data`;
CREATE TABLE `gift_coupon_data`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `assets` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '奖励内容',
  `comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for gift_coupon_player
-- ----------------------------
DROP TABLE IF EXISTS `gift_coupon_player`;
CREATE TABLE `gift_coupon_player`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `create_time` datetime(0) NULL DEFAULT NULL,
  `update_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4290 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for gjhhr_withdraw_status
-- ----------------------------
DROP TABLE IF EXISTS `gjhhr_withdraw_status`;
CREATE TABLE `gjhhr_withdraw_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `opt_time` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '每天第一次操作时间',
  `withdraw_num` tinyint(20) UNSIGNED NULL DEFAULT 0 COMMENT '提现次数',
  `withdraw_money` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '提现金额',
  PRIMARY KEY (`player_id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for goods_exchange_log
-- ----------------------------
DROP TABLE IF EXISTS `goods_exchange_log`;
CREATE TABLE `goods_exchange_log`  (
  `id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '日志唯一 id 号',
  `exchange_type` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '兑换类型：jing_bi, jipaiqi',
  `config_id` int(11) NOT NULL COMMENT '配置id，shoping_config 配置表中的 id 列',
  `diamond` bigint(20) NOT NULL COMMENT '消耗的钻石数量',
  `goods_value` bigint(20) NOT NULL COMMENT '买到的物品数量： 鲸币数量，记牌器小时数',
  `gift_asset` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '赠送的财富： json 数据',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '充值界面中 用代币（钻石）购买其他物品：鲸币、记牌器' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for goods_info
-- ----------------------------
DROP TABLE IF EXISTS `goods_info`;
CREATE TABLE `goods_info`  (
  `goods_id` int(11) NOT NULL,
  `goods_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `price` int(10) NULL DEFAULT NULL,
  PRIMARY KEY (`goods_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for goods_value
-- ----------------------------
DROP TABLE IF EXISTS `goods_value`;
CREATE TABLE `goods_value`  (
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `value` int(20) NULL DEFAULT NULL,
  PRIMARY KEY (`type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hb_log
-- ----------------------------
DROP TABLE IF EXISTS `hb_log`;
CREATE TABLE `hb_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'log_id',
  `game_level` int(50) NULL DEFAULT NULL COMMENT '游戏场次',
  `op_player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作玩家id',
  `op_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作类型，自己fa,别人qiang',
  `boom` int(5) NULL DEFAULT NULL COMMENT '是否暴雷0否1是',
  `asset_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '资产类型',
  `asset_value` bigint(255) NULL DEFAULT NULL COMMENT '资产数量',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '时间',
  `boom_value` bigint(255) NULL DEFAULT NULL COMMENT '踩雷赔付金额',
  `hb_id` int(50) NULL DEFAULT NULL COMMENT '红包id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `hb_id`(`hb_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1998646 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hb_player_info
-- ----------------------------
DROP TABLE IF EXISTS `hb_player_info`;
CREATE TABLE `hb_player_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `game_level` int(50) NOT NULL COMMENT '游戏等级',
  `use_num` int(10) NULL DEFAULT NULL COMMENT '使用次数',
  `total_num` int(10) NULL DEFAULT NULL COMMENT '总次数',
  `time` bigint(50) NULL DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`player_id`, `game_level`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hb_record
-- ----------------------------
DROP TABLE IF EXISTS `hb_record`;
CREATE TABLE `hb_record`  (
  `hb_id` int(50) NOT NULL COMMENT '红包id',
  `game_level` int(10) NOT NULL COMMENT '场次id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发红包的人',
  `asset_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '红包资产类型',
  `asset_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '红包资产金额',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '发红包的时间',
  `total_count` int(50) NULL DEFAULT NULL COMMENT '红包数量',
  `geted_count` int(50) NULL DEFAULT NULL COMMENT '已领取数量',
  `geted_myself` int(5) NULL DEFAULT NULL COMMENT '自己是否领取0否1是',
  `boom_num` int(10) NULL DEFAULT NULL COMMENT '雷号',
  `boom_count` int(10) NULL DEFAULT NULL COMMENT '踩雷数量',
  `boom_total` int(50) NULL DEFAULT NULL COMMENT '红包包内雷的总数',
  `is_deal` int(5) NULL DEFAULT NULL COMMENT '是否过期处理过 1处理过0未处理',
  PRIMARY KEY (`hb_id`, `game_level`) USING BTREE,
  INDEX `game_level`(`game_level`) USING BTREE,
  INDEX `is_deal`(`is_deal`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jykp_data
-- ----------------------------
DROP TABLE IF EXISTS `jykp_data`;
CREATE TABLE `jykp_data`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `period_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jykp_data_analyze
-- ----------------------------
DROP TABLE IF EXISTS `jykp_data_analyze`;
CREATE TABLE `jykp_data_analyze`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(50) NULL DEFAULT NULL COMMENT '玩家id',
  `period_id` int(11) NULL DEFAULT NULL COMMENT '期号',
  `bet_one` int(255) NULL DEFAULT NULL COMMENT '一号鱼押注2',
  `bet_two` int(255) NULL DEFAULT NULL COMMENT '二号鱼押注4',
  `bet_three` int(255) NULL DEFAULT NULL COMMENT '三号鱼押注6',
  `bet_four` int(255) NULL DEFAULT NULL COMMENT '四号鱼押注8',
  `bet_five` int(255) NULL DEFAULT NULL COMMENT '五号鱼押注12',
  `bet_six` int(255) NULL DEFAULT NULL COMMENT '六号鱼押注18',
  `bet_seven` int(255) NULL DEFAULT NULL COMMENT '七号鱼押注88',
  `is_fj` int(2) NULL DEFAULT NULL COMMENT '是否为金元宝事件，是为1，否为空',
  `award_one` int(255) NULL DEFAULT NULL COMMENT '一号鱼奖金2',
  `award_two` int(255) NULL DEFAULT NULL COMMENT '二号鱼奖金4',
  `award_three` int(255) NULL DEFAULT NULL COMMENT '三号鱼奖金6',
  `award_four` int(255) NULL DEFAULT NULL COMMENT '四号鱼奖金8',
  `award_five` int(255) NULL DEFAULT NULL COMMENT '五号鱼奖金12',
  `award_six` int(255) NULL DEFAULT NULL COMMENT '六号鱼奖金18',
  `award_seven` int(255) NULL DEFAULT NULL COMMENT '七号鱼奖金88',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 416188 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jykp_data_log
-- ----------------------------
DROP TABLE IF EXISTS `jykp_data_log`;
CREATE TABLE `jykp_data_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `period_id` int(50) NULL DEFAULT NULL COMMENT '期号',
  `hit_fish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '命中的鱼',
  `total_bet` int(255) NOT NULL COMMENT '总押注',
  `total_award` int(255) NULL DEFAULT NULL COMMENT '总奖金',
  `bet_one` int(255) NULL DEFAULT NULL COMMENT '一号鱼总押注2',
  `bet_two` int(255) NULL DEFAULT NULL COMMENT '二号鱼总押注4',
  `bet_three` int(255) NULL DEFAULT NULL COMMENT '三号鱼总押注6',
  `bet_four` int(255) NULL DEFAULT NULL COMMENT '四号鱼总押注8',
  `bet_five` int(255) NULL DEFAULT NULL COMMENT '五号鱼总押注12',
  `bet_six` int(255) NULL DEFAULT NULL COMMENT '六号鱼总押注18',
  `bet_seven` int(255) NULL DEFAULT NULL COMMENT '七号鱼总押注88',
  `is_fj` int(2) NULL DEFAULT NULL COMMENT '是否为金元宝事件，是为1，否为空',
  `award_one` int(255) NULL DEFAULT NULL COMMENT '一号鱼总奖金2',
  `award_two` int(255) NULL DEFAULT NULL COMMENT '二号鱼总奖金4',
  `award_three` int(255) NULL DEFAULT NULL COMMENT '三号鱼总奖金6',
  `award_four` int(255) NULL DEFAULT NULL COMMENT '四号鱼总奖金8',
  `award_five` int(255) NULL DEFAULT NULL COMMENT '五号鱼总奖金12',
  `award_six` int(255) NULL DEFAULT NULL COMMENT '六号鱼总奖金18',
  `award_seven` int(255) NULL DEFAULT NULL COMMENT '七号鱼总奖金88',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 361793 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for load_and_close_ser_cfg
-- ----------------------------
DROP TABLE IF EXISTS `load_and_close_ser_cfg`;
CREATE TABLE `load_and_close_ser_cfg`  (
  `id` int(11) NOT NULL,
  `path` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `startTime` datetime(0) NULL DEFAULT NULL,
  `closeTime` datetime(0) NULL DEFAULT NULL,
  `isover` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_apprentice_click_confirm
-- ----------------------------
DROP TABLE IF EXISTS `master_apprentice_click_confirm`;
CREATE TABLE `master_apprentice_click_confirm`  (
  `master_apprentice` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'p_id1 ..\'_\' .. p_id2',
  `is_click` int(4) NULL DEFAULT NULL COMMENT '是否点赞 0未点 1点赞',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '点赞时间',
  PRIMARY KEY (`master_apprentice`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_apprentice_like_num
-- ----------------------------
DROP TABLE IF EXISTS `master_apprentice_like_num`;
CREATE TABLE `master_apprentice_like_num`  (
  `master_apprentice` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'p_id1..\'_\'..p_id2',
  `like_num` int(50) NULL DEFAULT NULL COMMENT '某个徒弟对师父的点赞数',
  `use_free_box` int(4) NULL DEFAULT NULL COMMENT '是否使用 0没使用 1使用',
  `time` bigint(50) NULL DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`master_apprentice`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_apprentice_log
-- ----------------------------
DROP TABLE IF EXISTS `master_apprentice_log`;
CREATE TABLE `master_apprentice_log`  (
  `id` bigint(255) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源标志',
  `data` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'json数据',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_apprentice_ship
-- ----------------------------
DROP TABLE IF EXISTS `master_apprentice_ship`;
CREATE TABLE `master_apprentice_ship`  (
  `master_apprentice` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主键',
  `master` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '师父id',
  `apprentice` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '徒弟id',
  `recover_status` int(4) NULL DEFAULT NULL COMMENT '是否处于可恢复状态 1不处于 0处于恢复',
  `status` int(4) NULL DEFAULT NULL COMMENT '状态：0移除，1启用',
  PRIMARY KEY (`master_apprentice`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_apprentice_ship_list
-- ----------------------------
DROP TABLE IF EXISTS `master_apprentice_ship_list`;
CREATE TABLE `master_apprentice_ship_list`  (
  `id` int(11) NOT NULL COMMENT '主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `master_apprentice` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'p_id1中关于p_id2的消息',
  `type` int(5) NULL DEFAULT NULL COMMENT '消息类型：1申请，2解除，3恢复，4拒绝',
  `start_time` datetime(0) NULL DEFAULT NULL COMMENT '产生时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '处理时间',
  `flag` int(4) NULL DEFAULT NULL COMMENT '标志 0我的师父 1我的徒弟',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_dis_task_award_data
-- ----------------------------
DROP TABLE IF EXISTS `master_dis_task_award_data`;
CREATE TABLE `master_dis_task_award_data`  (
  `master_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '师父id',
  `apprentice_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '徒弟id',
  `task_id` int(11) NULL DEFAULT NULL COMMENT '完成的任务id',
  `award_valid_time` bigint(20) NULL DEFAULT NULL COMMENT '领奖的有效时间',
  `is_can_get_award` tinyint(10) NULL DEFAULT NULL COMMENT '能不能领(0不能领，1能领,2领过了)',
  PRIMARY KEY (`master_id`, `apprentice_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_dis_task_data
-- ----------------------------
DROP TABLE IF EXISTS `master_dis_task_data`;
CREATE TABLE `master_dis_task_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `master_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '师父id',
  `task_id` int(50) NULL DEFAULT NULL COMMENT '任务id',
  `dis_task_time` datetime(0) NULL DEFAULT NULL COMMENT '分发的时间',
  PRIMARY KEY (`player_id`, `master_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_dis_task_log
-- ----------------------------
DROP TABLE IF EXISTS `master_dis_task_log`;
CREATE TABLE `master_dis_task_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `master_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '师父id',
  `task_id` int(11) NULL DEFAULT NULL COMMENT '任务id',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_motivate_limit
-- ----------------------------
DROP TABLE IF EXISTS `master_motivate_limit`;
CREATE TABLE `master_motivate_limit`  (
  `player_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `money_limit` int(255) NULL DEFAULT NULL COMMENT '已使用金币',
  `time` bigint(20) NULL DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for master_square_info
-- ----------------------------
DROP TABLE IF EXISTS `master_square_info`;
CREATE TABLE `master_square_info`  (
  `id` int(50) NOT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `message_id` int(4) NULL DEFAULT NULL COMMENT '信息id',
  `publish_time` datetime(0) NULL DEFAULT NULL COMMENT '发布时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for match_nor_log
-- ----------------------------
DROP TABLE IF EXISTS `match_nor_log`;
CREATE TABLE `match_nor_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '比赛实例唯一id',
  `game_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '比赛唯一id',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `game_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `player_count` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '参赛人数',
  `races` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `MNL_game_id_index`(`game_id`) USING BTREE,
  INDEX `MNL_begin_time_index`(`begin_time`) USING BTREE,
  INDEX `MNL_game_name_index`(`name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for match_nor_player_log
-- ----------------------------
DROP TABLE IF EXISTS `match_nor_player_log`;
CREATE TABLE `match_nor_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `match_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '比赛实例唯一id',
  `score` int(10) NULL DEFAULT 0 COMMENT '成绩',
  `rank` int(10) NULL DEFAULT 0 COMMENT '名次',
  `award` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '奖励（json 字符串）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `MNPL_player_id_index`(`player_id`) USING BTREE,
  INDEX `MNPL_match_id_index`(`match_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 104447196 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家比赛日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for million_ddz_bonus_week
-- ----------------------------
DROP TABLE IF EXISTS `million_ddz_bonus_week`;
CREATE TABLE `million_ddz_bonus_week`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `bonus` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '比赛唯一id',
  PRIMARY KEY (`player_id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE,
  INDEX `rank`(`bonus`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for million_ddz_log
-- ----------------------------
DROP TABLE IF EXISTS `million_ddz_log`;
CREATE TABLE `million_ddz_log`  (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT '比赛实例唯一id',
  `game_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '比赛唯一id',
  `issue` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '比赛场次序号',
  `player_count` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '参赛人数',
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for million_ddz_player_log
-- ----------------------------
DROP TABLE IF EXISTS `million_ddz_player_log`;
CREATE TABLE `million_ddz_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '比赛实例唯一id',
  `issue` int(11) NULL DEFAULT NULL,
  `score` int(10) NULL DEFAULT 0 COMMENT '成绩',
  `final_round` int(11) NULL DEFAULT NULL,
  `final_win` int(11) NULL DEFAULT NULL,
  `award` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '奖励（json 字符串）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家比赛日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for million_ddz_race_log
-- ----------------------------
DROP TABLE IF EXISTS `million_ddz_race_log`;
CREATE TABLE `million_ddz_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_id` int(100) NULL DEFAULT 0 COMMENT '比赛实例id',
  `issue` int(11) NULL DEFAULT NULL,
  `round` int(10) NULL DEFAULT 0 COMMENT '轮序号',
  `race` int(10) NULL DEFAULT 0 COMMENT '局序号',
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `bomb_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数量',
  `spring` int(10) NULL DEFAULT 0 COMMENT '春天（0 无，1春天，2 反春）',
  `base_score` int(10) NULL DEFAULT 0 COMMENT '底分',
  `base_rate` int(10) NULL DEFAULT 0 COMMENT '底倍',
  `operation_list` varbinary(500) NULL DEFAULT 0 COMMENT '操作序列',
  `dizhu_seat` int(10) NULL DEFAULT 0 COMMENT '地主座位号',
  `seat1_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat2_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat3_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '对局日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for million_ddz_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `million_ddz_race_player_log`;
CREATE TABLE `million_ddz_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `race_id` int(10) NULL DEFAULT 0 COMMENT '对局id',
  `seat` int(10) NULL DEFAULT 0 COMMENT '座位号',
  `score` int(10) NULL DEFAULT 0 COMMENT '得分',
  `rate` int(10) NULL DEFAULT 0 COMMENT '倍数',
  `bomb_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数（自己的炸弹）',
  `spring` int(10) NULL DEFAULT 0 COMMENT '春天（0 无，1春天，2 反春，3 被春天，4被反春）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家对局日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for million_ddz_shared_status
-- ----------------------------
DROP TABLE IF EXISTS `million_ddz_shared_status`;
CREATE TABLE `million_ddz_shared_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `time` bigint(50) NULL DEFAULT 0 COMMENT '分享时间',
  `status` tinyint(4) UNSIGNED NULL DEFAULT 0,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for naming_match_join_id
-- ----------------------------
DROP TABLE IF EXISTS `naming_match_join_id`;
CREATE TABLE `naming_match_join_id`  (
  `id` int(50) UNSIGNED NOT NULL AUTO_INCREMENT,
  `match_id` int(10) NULL DEFAULT NULL,
  `join_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `status` tinyint(10) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5415 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for naming_match_players_info
-- ----------------------------
DROP TABLE IF EXISTS `naming_match_players_info`;
CREATE TABLE `naming_match_players_info`  (
  `match_id` int(10) NOT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `player_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `head_link` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `score` int(255) NULL DEFAULT 0,
  `hide_score` int(11) NULL DEFAULT 0,
  `rank` int(10) NULL DEFAULT 0,
  `join_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `status` tinyint(64) NULL DEFAULT 0,
  PRIMARY KEY (`match_id`, `player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for naming_match_rank
-- ----------------------------
DROP TABLE IF EXISTS `naming_match_rank`;
CREATE TABLE `naming_match_rank`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `match_id` int(10) NOT NULL,
  `match_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `match_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `player_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `head_link` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `score` int(255) NULL DEFAULT 0,
  `hide_score` int(11) NULL DEFAULT 0,
  `revive_num` tinyint(4) NULL DEFAULT 0,
  `award_hb` int(11) NULL DEFAULT 0 COMMENT '奖励的红包券',
  `rank` int(10) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 111053 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_ddz_nor_race_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_ddz_nor_race_log`;
CREATE TABLE `nor_ddz_nor_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_id` int(10) NULL DEFAULT NULL,
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `bomb_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数量',
  `spring` int(10) NULL DEFAULT 0 COMMENT '春天（0 无，1春天，2 反春）',
  `base_score` int(10) NULL DEFAULT 0 COMMENT '底分',
  `base_rate` int(10) NULL DEFAULT 0 COMMENT '底倍',
  `max_rate` int(10) NULL DEFAULT 0 COMMENT '底倍',
  `fapai` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '发的牌',
  `operation_list` varbinary(5000) NULL DEFAULT 0 COMMENT '操作序列',
  `dizhu_seat` int(10) NULL DEFAULT 0 COMMENT '地主座位号',
  `lz_card` int(10) NULL DEFAULT 0 COMMENT '癞子牌',
  `seat1_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat2_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat3_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_ddz_nor_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_ddz_nor_race_player_log`;
CREATE TABLE `nor_ddz_nor_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `race_id` int(11) NULL DEFAULT NULL,
  `seat` int(10) NULL DEFAULT 0 COMMENT '座位号',
  `score` int(10) NULL DEFAULT 0 COMMENT '得分',
  `rate` int(10) NULL DEFAULT 0 COMMENT '倍数',
  `bomb_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数（自己的炸弹）',
  `spring` int(10) NULL DEFAULT 0 COMMENT '春天（0 无，1春天，2 反春，3 被春天，4被反春）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `player_id`(`player_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 137157031 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_gobang_nor_race_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_gobang_nor_race_log`;
CREATE TABLE `nor_gobang_nor_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_id` int(10) NULL DEFAULT NULL,
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `base_score` int(10) NULL DEFAULT 0 COMMENT '底分',
  `base_rate` int(10) NULL DEFAULT 0 COMMENT '底倍',
  `max_rate` int(10) NULL DEFAULT 0 COMMENT '底倍',
  `operation_list` varbinary(5000) NULL DEFAULT 0 COMMENT '操作序列',
  `first_seat` int(10) NULL DEFAULT 0 COMMENT '黑棋座位号',
  `settle_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `seat1_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat2_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `ext_data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_gobang_nor_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_gobang_nor_race_player_log`;
CREATE TABLE `nor_gobang_nor_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `race_id` int(11) NULL DEFAULT NULL,
  `seat` int(10) NULL DEFAULT 0 COMMENT '座位号',
  `score` int(10) NULL DEFAULT 0 COMMENT '得分',
  `rate` int(10) NULL DEFAULT 0 COMMENT '倍数',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 97629 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_lhd_nor_race_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_lhd_nor_race_log`;
CREATE TABLE `nor_lhd_nor_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_id` int(10) NULL DEFAULT NULL,
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `base_score` int(10) NULL DEFAULT 0 COMMENT '底分',
  `base_rate` int(10) NULL DEFAULT 0 COMMENT '底倍',
  `operation_list` varbinary(5000) NULL DEFAULT 0 COMMENT '操作序列',
  `zhuang` tinyint(10) NULL DEFAULT 0 COMMENT '春天（0 无，1春天，2 反春）',
  `winner` tinyint(10) NULL DEFAULT 0 COMMENT '炸弹数量',
  `all_score` int(10) NULL DEFAULT 0 COMMENT '底倍',
  `win_pai_type` int(10) NULL DEFAULT 0 COMMENT '地主座位号',
  `seat1_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat2_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat3_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat4_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_lhd_nor_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_lhd_nor_race_player_log`;
CREATE TABLE `nor_lhd_nor_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `race_id` int(11) NULL DEFAULT NULL,
  `seat` int(10) NULL DEFAULT 0 COMMENT '座位号',
  `pai_type` int(10) NULL DEFAULT 0 COMMENT '得分',
  `win_score` int(10) NULL DEFAULT 0 COMMENT '倍数',
  `stake_score_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数（自己的炸弹）',
  `surrender` int(10) NULL DEFAULT 0 COMMENT '春天（0 无，1春天，2 反春，3 被春天，4被反春）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6490 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_mj_xzdd_race_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_mj_xzdd_race_log`;
CREATE TABLE `nor_mj_xzdd_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_id` int(11) NULL DEFAULT NULL,
  `game_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '游戏模式，比如： nor_mj_zdd',
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `init_rate` int(10) NULL DEFAULT NULL COMMENT '低倍',
  `init_stake` int(10) NULL DEFAULT 0 COMMENT '底分',
  `max_rate` int(10) NULL DEFAULT NULL,
  `fapai` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '发的牌',
  `operation_list` varbinary(1024) NULL DEFAULT 0 COMMENT '操作序列',
  `zhuang_seat` int(10) NULL DEFAULT 0 COMMENT '庄座位号',
  `seat1_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat2_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat3_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat4_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_mj_xzdd_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_mj_xzdd_race_player_log`;
CREATE TABLE `nor_mj_xzdd_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `race_id` int(11) NULL DEFAULT NULL,
  `seat` int(10) NULL DEFAULT 0 COMMENT '座位号',
  `score` int(10) NULL DEFAULT 0 COMMENT '得分',
  `multi` int(10) NULL DEFAULT 0 COMMENT '倍数',
  `gang_info` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0',
  `pai_info` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32647565 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_pdk_nor_race_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_pdk_nor_race_log`;
CREATE TABLE `nor_pdk_nor_race_log`  (
  `id` int(10) UNSIGNED NOT NULL COMMENT '对局id，自增长主键',
  `game_id` int(10) NULL DEFAULT NULL,
  `begin_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
  `bomb_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数量',
  `base_score` int(10) NULL DEFAULT 0 COMMENT '底分',
  `fapai` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '发的牌',
  `operation_list` varbinary(5000) NULL DEFAULT 0 COMMENT '操作序列',
  `first_cp_table_num` int(10) NULL DEFAULT 0 COMMENT '地主座位号',
  `seat1_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat2_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `seat3_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nor_pdk_nor_race_player_log
-- ----------------------------
DROP TABLE IF EXISTS `nor_pdk_nor_race_player_log`;
CREATE TABLE `nor_pdk_nor_race_player_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '对局id，自增长主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `race_id` int(11) NULL DEFAULT NULL,
  `seat` int(10) NULL DEFAULT 0 COMMENT '座位号',
  `score` int(10) NULL DEFAULT 0 COMMENT '得分',
  `bomb_count` int(10) NULL DEFAULT 0 COMMENT '炸弹数（自己的炸弹）',
  `bomb_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '炸弹结算信息',
  `type` int(10) NULL DEFAULT 0 COMMENT '0,失败 1,胜利2,被关 3,反关 4,单关 5,双关6,包赔 7,被包赔',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8687698 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for o_asset_change_type
-- ----------------------------
DROP TABLE IF EXISTS `o_asset_change_type`;
CREATE TABLE `o_asset_change_type`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id',
  `flag` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标识',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '名称',
  `createtime` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `updatetime` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `OACT_flag_unique`(`flag`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for object_attribute
-- ----------------------------
DROP TABLE IF EXISTS `object_attribute`;
CREATE TABLE `object_attribute`  (
  `object_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '唯一编号',
  `attribute_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '属性名字',
  `attribute_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '属性值',
  PRIMARY KEY (`object_id`, `attribute_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pceggs_player_data
-- ----------------------------
DROP TABLE IF EXISTS `pceggs_player_data`;
CREATE TABLE `pceggs_player_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ddz_round_count` int(255) NULL DEFAULT NULL COMMENT '斗地主局数',
  `win_jingbi` bigint(20) NULL DEFAULT NULL COMMENT '累积赢金币（从任务拿，暂废弃）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_10_gift_bag_status
-- ----------------------------
DROP TABLE IF EXISTS `player_10_gift_bag_status`;
CREATE TABLE `player_10_gift_bag_status`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `status` tinyint(20) NULL DEFAULT 0,
  `time` date NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_2_gift_bag_status
-- ----------------------------
DROP TABLE IF EXISTS `player_2_gift_bag_status`;
CREATE TABLE `player_2_gift_bag_status`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `status` tinyint(20) NULL DEFAULT 0,
  `time` date NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_act_permission_data
-- ----------------------------
DROP TABLE IF EXISTS `player_act_permission_data`;
CREATE TABLE `player_act_permission_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `permission` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '权限名( 包括活动&精准推送的任务id )',
  `is_work` tinyint(10) NULL DEFAULT NULL COMMENT '是否工作(0就是不能，1就是能)',
  `is_lock` tinyint(10) NULL DEFAULT 0 COMMENT '是否锁定，默认是0不锁定，1是锁定(锁定之后,is_work不能变)',
  `last_deal_time` bigint(50) NULL DEFAULT 0 COMMENT '上次处理的时间',
  PRIMARY KEY (`player_id`, `permission`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_act_permission_info
-- ----------------------------
DROP TABLE IF EXISTS `player_act_permission_info`;
CREATE TABLE `player_act_permission_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `last_deal_time` bigint(50) NULL DEFAULT NULL COMMENT '上次处理的时间',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_alipay_account
-- ----------------------------
DROP TABLE IF EXISTS `player_alipay_account`;
CREATE TABLE `player_alipay_account`  (
  `player_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `alipay_account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_ancestor
-- ----------------------------
DROP TABLE IF EXISTS `player_ancestor`;
CREATE TABLE `player_ancestor`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家 id',
  `parent_1` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_2` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_3` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_4` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_5` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_6` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_7` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_8` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_9` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_10` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_11` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_12` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_13` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_14` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_15` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_16` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_17` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_18` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_19` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_20` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_21` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  `parent_22` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '上级id',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_asset
-- ----------------------------
DROP TABLE IF EXISTS `player_asset`;
CREATE TABLE `player_asset`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `diamond` bigint(20) NULL DEFAULT 0 COMMENT '钻石',
  `jing_bi` bigint(20) NULL DEFAULT 0,
  `shop_ticket` bigint(20) NULL DEFAULT 0 COMMENT '抵用券',
  `cash` bigint(20) NULL DEFAULT 0 COMMENT '现金',
  `shop_gold_sum` bigint(20) NULL DEFAULT 0 COMMENT '购物金，各面额的总数',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_asset_log
-- ----------------------------
DROP TABLE IF EXISTS `player_asset_log`;
CREATE TABLE `player_asset_log`  (
  `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志 id ，主键',
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `date` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  `asset_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '财物类型： match_ticket, room_card,shop_gold,cash',
  `change_value` bigint(20) NULL DEFAULT NULL COMMENT '变化量',
  `change_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '变化原因： weixin 微信充值； ali_pay 支付宝充值； 。。。',
  `current` bigint(20) NULL DEFAULT NULL COMMENT '变化后数量',
  `change_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '编号ID，外部数据，（如订单ID，对局ID）',
  `sync_seq` bigint(255) NULL DEFAULT NULL COMMENT '同步序号',
  `change_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `change_way_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `sync_seq`(`sync_seq`) USING BTREE,
  INDEX `id`(`id`) USING BTREE,
  INDEX `index2`(`asset_type`, `date`, `change_type`, `change_value`, `change_id`) USING BTREE,
  INDEX `index3`(`change_type`, `date`, `asset_type`, `change_value`, `change_id`) USING BTREE,
  INDEX `index4`(`change_id`, `date`, `asset_type`, `change_type`, `change_value`) USING BTREE,
  INDEX `change_value`(`change_value`, `date`, `asset_type`, `change_type`, `change_id`) USING BTREE,
  INDEX `date`(`date`, `asset_type`, `change_type`, `change_value`, `change_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 845503422 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_asset_refund
-- ----------------------------
DROP TABLE IF EXISTS `player_asset_refund`;
CREATE TABLE `player_asset_refund`  (
  `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志 id ，主键',
  `log_id_refund` int(10) UNSIGNED NOT NULL COMMENT '退款的日志id（目前只有报名费）',
  `seq_refund` bigint(50) NULL DEFAULT 0 COMMENT '退款的同步序号',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `log_id_refund`(`log_id_refund`) USING BTREE,
  INDEX `seq_refund`(`seq_refund`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 630867 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'player_asset_log 表中 的退款记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_block_status
-- ----------------------------
DROP TABLE IF EXISTS `player_block_status`;
CREATE TABLE `player_block_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `block_status` tinyint(50) NULL DEFAULT 1,
  `block_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '昵称',
  `reason` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `op_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '操作人',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_block_status_log
-- ----------------------------
DROP TABLE IF EXISTS `player_block_status_log`;
CREATE TABLE `player_block_status_log`  (
  `id` int(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `block_status` tinyint(50) NULL DEFAULT 1,
  `reason` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `log_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  `op_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '操作人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 216 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_broke_beg
-- ----------------------------
DROP TABLE IF EXISTS `player_broke_beg`;
CREATE TABLE `player_broke_beg`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `num` tinyint(20) NULL DEFAULT 0,
  `time` bigint(20) NULL DEFAULT 0,
  `start_time` bigint(20) NULL DEFAULT 0 COMMENT '开始时间（目前为首次登录时间）',
  PRIMARY KEY (`player_id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '免费领金币' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_broke_subsidy
-- ----------------------------
DROP TABLE IF EXISTS `player_broke_subsidy`;
CREATE TABLE `player_broke_subsidy`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `num` tinyint(20) NULL DEFAULT 0,
  `time` bigint(20) NULL DEFAULT 0,
  `free_num` tinyint(5) NULL DEFAULT 0,
  `free_time` bigint(20) NULL DEFAULT 0,
  `start_time` bigint(20) NULL DEFAULT 0 COMMENT '开始时间（目前为首次登录时间）',
  PRIMARY KEY (`player_id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_buyu_rank_data
-- ----------------------------
DROP TABLE IF EXISTS `player_buyu_rank_data`;
CREATE TABLE `player_buyu_rank_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `total_profit_num` bigint(50) NULL DEFAULT NULL COMMENT '总共的盈利数量',
  `player_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家昵称',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_buyu_rank_log
-- ----------------------------
DROP TABLE IF EXISTS `player_buyu_rank_log`;
CREATE TABLE `player_buyu_rank_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `player_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家名',
  `score` bigint(50) NULL DEFAULT NULL COMMENT '分数',
  `rank` mediumint(30) NULL DEFAULT NULL COMMENT '排名',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3677 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_change_type_refund
-- ----------------------------
DROP TABLE IF EXISTS `player_change_type_refund`;
CREATE TABLE `player_change_type_refund`  (
  `change_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '变化原因',
  `change_type_refund` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退款的变化原因',
  PRIMARY KEY (`change_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '退款的消费类型定义表。记录 退款 和 消费 的类型对应关系' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_charge_lottery_award_log
-- ----------------------------
DROP TABLE IF EXISTS `player_charge_lottery_award_log`;
CREATE TABLE `player_charge_lottery_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `game_num` smallint(20) NULL DEFAULT NULL COMMENT '第几次游戏(摇色子)',
  `award_id` smallint(20) NULL DEFAULT NULL COMMENT '要中的奖励id',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2119 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_charge_lottery_data
-- ----------------------------
DROP TABLE IF EXISTS `player_charge_lottery_data`;
CREATE TABLE `player_charge_lottery_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `now_game_profit_acc` int(50) NULL DEFAULT NULL COMMENT '当前的游戏累积赢金',
  `now_charge_profit_acc` mediumint(30) NULL DEFAULT NULL COMMENT '当前的充值累积',
  `now_credits` mediumint(30) NULL DEFAULT NULL COMMENT '当前的积分数量',
  `now_game_num` smallint(20) NULL DEFAULT NULL COMMENT '当前游戏了多少次，摇了多少次色子',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_consume_statistics
-- ----------------------------
DROP TABLE IF EXISTS `player_consume_statistics`;
CREATE TABLE `player_consume_statistics`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `pay` bigint(50) NULL DEFAULT 0,
  `cost_jing_bi` bigint(50) NULL DEFAULT 0,
  `cost_shop_gold` bigint(50) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '登录表\r\n近期登陆数据，离线超过一定时间则删除' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_da_fu_hao_award_log
-- ----------------------------
DROP TABLE IF EXISTS `player_da_fu_hao_award_log`;
CREATE TABLE `player_da_fu_hao_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `game_num` smallint(20) NULL DEFAULT NULL COMMENT '第几次游戏(摇色子)',
  `award_id` smallint(20) NULL DEFAULT NULL COMMENT '要中的奖励id',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11126 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_da_fu_hao_data
-- ----------------------------
DROP TABLE IF EXISTS `player_da_fu_hao_data`;
CREATE TABLE `player_da_fu_hao_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `now_game_profit_acc` int(50) NULL DEFAULT NULL COMMENT '当前的游戏累积赢金',
  `now_charge_profit_acc` mediumint(30) NULL DEFAULT NULL COMMENT '当前的充值累积',
  `now_credits` mediumint(30) NULL DEFAULT NULL COMMENT '当前的积分数量',
  `now_game_num` smallint(20) NULL DEFAULT NULL COMMENT '当前游戏了多少次，摇了多少次色子',
  `have_get_award_num` smallint(20) NULL DEFAULT 0 COMMENT '奖励领取的状态数字',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_device_info
-- ----------------------------
DROP TABLE IF EXISTS `player_device_info`;
CREATE TABLE `player_device_info`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `device_token` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '这家伙很懒，什么也没留下。' COMMENT '设备编号',
  `device_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '设备类型； ios / android',
  `refresh_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家最近使用的设备信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_discount_asset
-- ----------------------------
DROP TABLE IF EXISTS `player_discount_asset`;
CREATE TABLE `player_discount_asset`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `asset_type` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `asset_value` bigint(50) NULL DEFAULT 0 COMMENT '数量',
  PRIMARY KEY (`player_id`, `asset_type`) USING BTREE,
  INDEX `ID_UNIQUE`(`player_id`) USING BTREE,
  INDEX `index3`(`asset_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_dress_info
-- ----------------------------
DROP TABLE IF EXISTS `player_dress_info`;
CREATE TABLE `player_dress_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `dress_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '有效期',
  `dress_id` int(255) NOT NULL DEFAULT 0,
  `num` int(255) NULL DEFAULT NULL,
  `time` bigint(255) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`, `dress_type`, `dress_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_dress_info_log
-- ----------------------------
DROP TABLE IF EXISTS `player_dress_info_log`;
CREATE TABLE `player_dress_info_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `dress_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '有效期',
  `dress_id` int(255) NULL DEFAULT 0,
  `num` int(255) NULL DEFAULT NULL,
  `time` bigint(255) NULL DEFAULT NULL,
  `change_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `log_time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 89605 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_dressed
-- ----------------------------
DROP TABLE IF EXISTS `player_dressed`;
CREATE TABLE `player_dressed`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `dressed_head_frame` tinyint(20) NULL DEFAULT 0 COMMENT '有效期',
  PRIMARY KEY (`player_id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_duiju_hongbao_award
-- ----------------------------
DROP TABLE IF EXISTS `player_duiju_hongbao_award`;
CREATE TABLE `player_duiju_hongbao_award`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `get_award_value` int(50) NULL DEFAULT NULL COMMENT '当日已经获得的对局红包',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_everyday_share_act_award_log
-- ----------------------------
DROP TABLE IF EXISTS `player_everyday_share_act_award_log`;
CREATE TABLE `player_everyday_share_act_award_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `player_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家昵称',
  `award_id` int(50) NULL DEFAULT NULL COMMENT '奖励id',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3138 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_everyday_share_act_awards
-- ----------------------------
DROP TABLE IF EXISTS `player_everyday_share_act_awards`;
CREATE TABLE `player_everyday_share_act_awards`  (
  `award_id` tinyint(10) NOT NULL COMMENT '奖励id',
  `remain_num` int(50) NULL DEFAULT NULL COMMENT '剩余数量',
  PRIMARY KEY (`award_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_everyday_share_act_data
-- ----------------------------
DROP TABLE IF EXISTS `player_everyday_share_act_data`;
CREATE TABLE `player_everyday_share_act_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `is_get_award` tinyint(10) NULL DEFAULT 0 COMMENT '是否领过奖励, 0 false 1 true',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_everyday_shared_status
-- ----------------------------
DROP TABLE IF EXISTS `player_everyday_shared_status`;
CREATE TABLE `player_everyday_shared_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `status` tinyint(4) UNSIGNED NULL DEFAULT 0,
  `time` bigint(50) NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_ext_status
-- ----------------------------
DROP TABLE IF EXISTS `player_ext_status`;
CREATE TABLE `player_ext_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `status` int(4) NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`, `type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_freestyle_water_pool_data
-- ----------------------------
DROP TABLE IF EXISTS `player_freestyle_water_pool_data`;
CREATE TABLE `player_freestyle_water_pool_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` int(11) NULL DEFAULT NULL,
  `value` bigint(20) NULL DEFAULT 0,
  `win_seq` int(11) NULL DEFAULT 0 COMMENT '连续输赢次数',
  UNIQUE INDEX `1`(`player_id`, `game_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_gift_bag_status
-- ----------------------------
DROP TABLE IF EXISTS `player_gift_bag_status`;
CREATE TABLE `player_gift_bag_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `gift_bag_id` int(4) NOT NULL,
  `gift_bag_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `num` int(20) NULL DEFAULT 0,
  `time` bigint(20) NULL DEFAULT 0,
  `permit_num` int(10) NULL DEFAULT 0,
  `permit_time` bigint(20) NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `gift_bag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_gift_coupon_log
-- ----------------------------
DROP TABLE IF EXISTS `player_gift_coupon_log`;
CREATE TABLE `player_gift_coupon_log`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `parent_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `gift_coupon_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL COMMENT '礼券内容',
  `time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`player_id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_gjhhr
-- ----------------------------
DROP TABLE IF EXISTS `player_gjhhr`;
CREATE TABLE `player_gjhhr`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家 id',
  `gjhhr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所属的高级合伙人',
  `offspring_num` int(11) NOT NULL COMMENT '在高级合伙人中的 后代级数，自己就是 0',
  PRIMARY KEY (`player_id`, `gjhhr`) USING BTREE,
  INDEX `gjhhr`(`gjhhr`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家所属的高级合伙人' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_glory
-- ----------------------------
DROP TABLE IF EXISTS `player_glory`;
CREATE TABLE `player_glory`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `level` tinyint(20) NULL DEFAULT 0 COMMENT '有效期',
  `score` int(20) NULL DEFAULT 0 COMMENT '0 or 1',
  PRIMARY KEY (`player_id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_goldpig_info
-- ----------------------------
DROP TABLE IF EXISTS `player_goldpig_info`;
CREATE TABLE `player_goldpig_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `is_buy_goldpig` tinyint(10) NULL DEFAULT NULL COMMENT '是否购买金猪礼包(旧版)',
  `remain_task_num` mediumint(20) NULL DEFAULT NULL COMMENT '剩余的任务次数(旧版)',
  `is_buy_goldpig1` tinyint(10) NULL DEFAULT 0 COMMENT '是否购买 新版 金猪礼包1',
  `remain_task_num1` mediumint(20) NULL DEFAULT 0 COMMENT '新版金猪礼包1剩余的任务次数',
  `is_buy_goldpig2` tinyint(10) NULL DEFAULT 0 COMMENT '是否购买金猪礼包2',
  `remain_task_num2` mediumint(20) NULL DEFAULT 0 COMMENT '金猪礼包2剩余的任务次数',
  `today_get_task_num2` mediumint(20) NULL DEFAULT 0 COMMENT '金猪礼包2任务今日领取的次数',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_hb_history
-- ----------------------------
DROP TABLE IF EXISTS `player_hb_history`;
CREATE TABLE `player_hb_history`  (
  `history_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `game_level` int(50) NOT NULL COMMENT '游戏场次',
  `op_player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作玩家id',
  `op_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作类型，自己fa,别人qiang',
  `boom` int(5) NULL DEFAULT NULL COMMENT '是否暴雷0否1是',
  `asset_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '资产类型',
  `asset_value` bigint(255) NULL DEFAULT NULL COMMENT '资产数量',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '时间',
  `boom_value` bigint(255) NULL DEFAULT NULL COMMENT '踩雷赔付金额',
  `hb_id` int(50) NULL DEFAULT NULL COMMENT '红包id',
  PRIMARY KEY (`history_id`, `game_level`, `op_player_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_info
-- ----------------------------
DROP TABLE IF EXISTS `player_info`;
CREATE TABLE `player_info`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `sync_seq` int(11) NOT NULL DEFAULT 0 COMMENT '用户信息的同步序号,供后台业务系统同步数据',
  `kind` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'normal' COMMENT '种类： \'normal\',\'robot\',\'admin\'',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '未登陆用户' COMMENT '昵称',
  `head_image` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'http://jydown.jyhd919.cn/head_images/icon_128.png' COMMENT '头像,http链接',
  `sex` tinyint(11) NULL DEFAULT 1 COMMENT '性别： 0 女，1 男',
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `ali_pay` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '付宝号',
  `wechat` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '微信号',
  `sign` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '这家伙很懒，什么也没留下。' COMMENT '个人签名',
  `is_block` int(11) NULL DEFAULT 0 COMMENT '是否锁定； 0 未锁定； 1 锁定',
  `logined` tinyint(4) NULL DEFAULT 0 COMMENT '是否登录过：0 未登录；1 已登录',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `index2`(`sync_seq`) USING BTREE,
  INDEX `kind`(`kind`) USING BTREE,
  INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_ji_pai_qi
-- ----------------------------
DROP TABLE IF EXISTS `player_ji_pai_qi`;
CREATE TABLE `player_ji_pai_qi`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `valid_time` bigint(20) NULL DEFAULT 0 COMMENT '有效期',
  `always` tinyint(20) NULL DEFAULT 0 COMMENT '0 or 1',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_ji_pai_qi_log
-- ----------------------------
DROP TABLE IF EXISTS `player_ji_pai_qi_log`;
CREATE TABLE `player_ji_pai_qi_log`  (
  `id` int(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `change_time` int(20) NULL DEFAULT 0,
  `valid_time` bigint(20) NULL DEFAULT 0 COMMENT '有效期',
  `always` tinyint(4) NULL DEFAULT NULL,
  `change_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '变化原因： weixin 微信充值； ali_pay 支付宝充值； 。。。',
  `change_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '编号ID，外部数据，（如订单ID，对局ID）',
  `change_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `change_way_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 67425 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_last_asset_map
-- ----------------------------
DROP TABLE IF EXISTS `player_last_asset_map`;
CREATE TABLE `player_last_asset_map`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `jing_bi` bigint(50) NULL DEFAULT NULL COMMENT '鲸币数量',
  `shop_gold_sum` bigint(50) NULL DEFAULT NULL COMMENT '红包劵总数',
  `total_charge` bigint(50) NULL DEFAULT NULL COMMENT '总充值',
  `dui_shiwu_gold` bigint(50) NULL DEFAULT NULL COMMENT '兑换成实物的红包劵',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_like_num
-- ----------------------------
DROP TABLE IF EXISTS `player_like_num`;
CREATE TABLE `player_like_num`  (
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `total_like_num` int(11) NULL DEFAULT NULL COMMENT '获得赞的总数',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_login
-- ----------------------------
DROP TABLE IF EXISTS `player_login`;
CREATE TABLE `player_login`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家登陆的 ip 地址',
  `login_os` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家登陆的操作系统',
  `login_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '玩家登陆时间',
  `logout_time` datetime(0) NULL DEFAULT NULL COMMENT '玩家登出时间',
  `on_line` int(11) NULL DEFAULT NULL COMMENT '当前是否在线： 1 在线； NULL  离线',
  `log_id` int(10) NOT NULL COMMENT '日志表中对应的 log_id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '登录表\r\n近期登陆数据，离线超过一定时间则删除' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_login_log
-- ----------------------------
DROP TABLE IF EXISTS `player_login_log`;
CREATE TABLE `player_login_log`  (
  `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志 id ，主键',
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `login_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家登陆的 ip 地址',
  `login_os` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家登陆的操作系统',
  `login_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '玩家登陆时间',
  `logout_time` datetime(0) NULL DEFAULT NULL COMMENT '玩家登出时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  UNIQUE INDEX `log_id_UNIQUE`(`log_id`) USING BTREE,
  INDEX `login_time`(`login_time`) USING BTREE,
  INDEX `id`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 88834233 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '登录日志表\r\n' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_login_stat
-- ----------------------------
DROP TABLE IF EXISTS `player_login_stat`;
CREATE TABLE `player_login_stat`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `first_login_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '玩家登陆时间',
  `first_log_id` int(10) NOT NULL COMMENT '日志表中对应的 log_id',
  `last_login_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '玩家登陆时间',
  `last_log_id` int(10) NOT NULL COMMENT '日志表中对应的 log_id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `PLS_first_login_time_index`(`first_login_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '登录统计表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_lottery
-- ----------------------------
DROP TABLE IF EXISTS `player_lottery`;
CREATE TABLE `player_lottery`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `lottery_num` int(20) NULL DEFAULT 0,
  `lottery_time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_lottery_copy1
-- ----------------------------
DROP TABLE IF EXISTS `player_lottery_copy1`;
CREATE TABLE `player_lottery_copy1`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `lottery_num` int(20) NULL DEFAULT 0,
  `lottery_time` int(20) NULL DEFAULT 0,
  `lottery_asset` int(20) NULL DEFAULT 0,
  `lottery_item_count` int(11) NULL DEFAULT NULL,
  `lottery_asset_time` bigint(50) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_lottery_luck_box
-- ----------------------------
DROP TABLE IF EXISTS `player_lottery_luck_box`;
CREATE TABLE `player_lottery_luck_box`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `id` tinyint(4) NOT NULL DEFAULT 0,
  `open` tinyint(4) NULL DEFAULT 0 COMMENT '是否开启',
  `lottery_num` tinyint(4) NULL DEFAULT 0,
  `lottery_jb_num` tinyint(4) NULL DEFAULT NULL,
  `lottery_time` bigint(50) NULL DEFAULT NULL,
  `lottery_result` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `box` tinyint(4) NULL DEFAULT 0,
  `round` tinyint(4) NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_lottery_luck_box_low
-- ----------------------------
DROP TABLE IF EXISTS `player_lottery_luck_box_low`;
CREATE TABLE `player_lottery_luck_box_low`  (
  `id` int(4) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `time` datetime(4) NULL COMMENT '是否开启',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `one`(`player_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_match_water
-- ----------------------------
DROP TABLE IF EXISTS `player_match_water`;
CREATE TABLE `player_match_water`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `game_id` int(11) NOT NULL COMMENT '场次id',
  `water` bigint(255) NULL DEFAULT 0 COMMENT '水池的值',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `player_id`(`player_id`, `game_id`) USING BTREE,
  INDEX `game_id`(`game_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5733290 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_merchant_order
-- ----------------------------
DROP TABLE IF EXISTS `player_merchant_order`;
CREATE TABLE `player_merchant_order`  (
  `order_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '订单号',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `amount` bigint(11) NOT NULL DEFAULT 0 COMMENT '消费总额',
  `props_json` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '消费多个面额消费张数的json: {\"10\":2,\"30\":1}',
  `shoping_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '本次购买的描述信息，比如： 购买 xxx 商品 nnn 件。',
  `shoping_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '购物时间',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `order_id_UNIQUE`(`order_id`) USING BTREE,
  INDEX `index_shoping_time`(`shoping_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家在线下商家消费的订单表。' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_new_vip_data
-- ----------------------------
DROP TABLE IF EXISTS `player_new_vip_data`;
CREATE TABLE `player_new_vip_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `vip_level` smallint(20) NULL DEFAULT NULL COMMENT 'vip等级',
  `now_charge_sum` int(50) NULL DEFAULT NULL COMMENT '当前的总共充值',
  `now_cahrge_value` int(50) NULL DEFAULT NULL COMMENT '当前的充值数(用来做vip等级增加的值)',
  `is_send_email` int(50) NULL DEFAULT 0 COMMENT '是否发送升级邮件,二进制每一个位表示是否',
  `is_upgrade` tinyint(10) NULL DEFAULT 0 COMMENT '是否升级为最新的配置',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_new_vip_rights_data
-- ----------------------------
DROP TABLE IF EXISTS `player_new_vip_rights_data`;
CREATE TABLE `player_new_vip_rights_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `rights_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'vip的权益类型',
  `rights_value` int(50) NULL DEFAULT NULL COMMENT '当前权益的值',
  `last_op_time` datetime(0) NULL DEFAULT NULL COMMENT '上次操作的时间',
  PRIMARY KEY (`player_id`, `rights_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_object
-- ----------------------------
DROP TABLE IF EXISTS `player_object`;
CREATE TABLE `player_object`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '所属玩家',
  `object_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '唯一编号',
  `object_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '类型',
  PRIMARY KEY (`player_id`, `object_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_object_log
-- ----------------------------
DROP TABLE IF EXISTS `player_object_log`;
CREATE TABLE `player_object_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '所属玩家',
  `object_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '唯一编号',
  `object_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '类型',
  `object_opt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `ori_attribute` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `final_attribute` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  `change_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `change_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `change_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `change_way_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2152956 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_offspring
-- ----------------------------
DROP TABLE IF EXISTS `player_offspring`;
CREATE TABLE `player_offspring`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家 di',
  `offspring_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '后代',
  `offsprint_parent_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '后代 offspring_id 的直接父亲 ',
  `offspring_num` int(11) NOT NULL COMMENT '后代级数，自己就是 0',
  PRIMARY KEY (`player_id`, `offspring_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家后代表，玩家的所有 子孙 后代 ，包括 自己' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_offspring_prepare
-- ----------------------------
DROP TABLE IF EXISTS `player_offspring_prepare`;
CREATE TABLE `player_offspring_prepare`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家 di',
  `offspring_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '后代',
  `offsprint_parent_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '后代 offspring_id 的直接父亲 ',
  `offspring_num` int(11) NOT NULL COMMENT '后代级数，自己就是 0',
  PRIMARY KEY (`player_id`, `offspring_id`) USING BTREE,
  INDEX `offspring_id`(`offspring_id`) USING BTREE,
  INDEX `offspring_num`(`offspring_num`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家后代表，玩家的所有 子孙 后代 ，包括 自己' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_open_id
-- ----------------------------
DROP TABLE IF EXISTS `player_open_id`;
CREATE TABLE `player_open_id`  (
  `player_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `app_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`, `app_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_other_base_info
-- ----------------------------
DROP TABLE IF EXISTS `player_other_base_info`;
CREATE TABLE `player_other_base_info`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `real_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `weixin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `shengfen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `chengshi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `qu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_other_base_info_change_log
-- ----------------------------
DROP TABLE IF EXISTS `player_other_base_info_change_log`;
CREATE TABLE `player_other_base_info_change_log`  (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `real_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `weixin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `shengfen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `chengshi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `qu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `op_player` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 360 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_pay_order
-- ----------------------------
DROP TABLE IF EXISTS `player_pay_order`;
CREATE TABLE `player_pay_order`  (
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '我们自己的订单ID',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id\n\n10111111111，ID由11位数字组成，前两位表示服务器号',
  `order_status` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'create' COMMENT '订单状态（\"init\" - 初始状态,\"create\" - 支付渠道已创建订单,\"error\" - 出错,\"fail\" - 失败,\"complete\" - 支付成功）',
  `error_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `money_type` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'rmb' COMMENT '货币类型（如 rmb,dollar）',
  `money` int(11) NOT NULL DEFAULT 0 COMMENT '充值数量（单位：分）',
  `channel_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '支付渠道',
  `channel_account_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `source_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'game' COMMENT '来源类型： game 游戏内部； wxgzh 微信公众号',
  `product_id` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '我们自己的商品id',
  `product_count` int(11) NULL DEFAULT 1 COMMENT '商品数量',
  `product_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '商品描述，用于显示在支付界面上',
  `is_test` int(11) NULL DEFAULT 0 COMMENT '是否是测试（1表示测试，0 表示真',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `channel_product_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道方的产品id',
  `channel_order_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道方的订单id',
  `itunes_trans_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'itunes 验证ID',
  `end_time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '完成时间',
  PRIMARY KEY (`order_id`) USING BTREE,
  INDEX `index2`(`player_id`) USING BTREE,
  INDEX `create_time`(`create_time`) USING BTREE,
  INDEX `order_status`(`order_status`) USING BTREE,
  INDEX `channel_type`(`channel_type`) USING BTREE,
  INDEX `product_id`(`product_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家充值订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_pay_order_3rd
-- ----------------------------
DROP TABLE IF EXISTS `player_pay_order_3rd`;
CREATE TABLE `player_pay_order_3rd`  (
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '我们自己的订单ID',
  `order_status` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'create' COMMENT '订单状态，和通用订单表相同',
  `channel_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '支付渠道',
  `subtype` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子类型（可选，渠道内部分类）',
  `billno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方的订单号',
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方的订单token，用于验证',
  `extend1` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方的扩展数据1',
  `extend2` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方的扩展数据2',
  `extend3` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方的扩展数据3',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '订单的第三方sdk信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_pay_order_detail
-- ----------------------------
DROP TABLE IF EXISTS `player_pay_order_detail`;
CREATE TABLE `player_pay_order_detail`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '我们自己的订单ID',
  `asset_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资产类型',
  `asset_count` bigint(20) NOT NULL COMMENT '资产数量',
  `asset_attribute` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资产属性(obj类型道具才有)',
  `goods_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'buy' COMMENT '商品类型： \"buy\",\"gift\"',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1609804 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家充值订单详情表\r\n\r\n订单中的每个购买项' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_pay_order_detail_log
-- ----------------------------
DROP TABLE IF EXISTS `player_pay_order_detail_log`;
CREATE TABLE `player_pay_order_detail_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '我们自己的订单ID',
  `asset_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资产类型',
  `asset_count` bigint(20) NOT NULL COMMENT '资产数量',
  `asset_attribute` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资产属性(obj类型道具才有)',
  `goods_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'buy' COMMENT '商品类型： \"buy\",\"gift\"',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2179328 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家充值订单详情表\r\n\r\n订单中的每个购买项' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_pay_order_log
-- ----------------------------
DROP TABLE IF EXISTS `player_pay_order_log`;
CREATE TABLE `player_pay_order_log`  (
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '我们自己的订单ID',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id\n\n10111111111，ID由11位数字组成，前两位表示服务器号',
  `order_status` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'create' COMMENT '订单状态（\"init\" - 初始状态,\"create\" - 支付渠道已创建订单,\"error\" - 出错,\"fail\" - 失败,\"complete\" - 支付成功）',
  `error_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `money_type` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'rmb' COMMENT '货币类型（如 rmb,dollar）',
  `money` int(11) NOT NULL DEFAULT 0 COMMENT '充值数量（单位：分）',
  `channel_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '支付渠道',
  `channel_account_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `source_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'game' COMMENT '来源类型： game 游戏内部； wxgzh 微信公众号',
  `product_id` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '我们自己的商品id',
  `product_count` int(11) NULL DEFAULT 1 COMMENT '商品数量',
  `product_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '商品描述，用于显示在支付界面上',
  `is_test` int(11) NULL DEFAULT 0 COMMENT '是否是测试（1表示测试，0 表示真',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `channel_product_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道方的产品id',
  `channel_order_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道方的订单id',
  `itunes_trans_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'itunes 验证ID',
  `end_time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '完成时间',
  PRIMARY KEY (`order_id`) USING BTREE,
  INDEX `create_time`(`create_time`) USING BTREE,
  INDEX `order_status`(`order_status`) USING BTREE,
  INDEX `channel_type`(`channel_type`) USING BTREE,
  INDEX `index2`(`player_id`) USING BTREE,
  INDEX `product_id`(`product_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家充值订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_pay_order_stat
-- ----------------------------
DROP TABLE IF EXISTS `player_pay_order_stat`;
CREATE TABLE `player_pay_order_stat`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id\n\n10111111111，ID由11位数字组成，前两位表示服务器号',
  `first_complete_time` datetime(0) NULL DEFAULT NULL COMMENT '第一个订单完成时间',
  `first_order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '第一个订单ID',
  `last_complete_time` datetime(0) NULL DEFAULT NULL COMMENT '第二个订单完成时间',
  `last_order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '第二个订单ID',
  `sum_money` int(11) NOT NULL DEFAULT 0 COMMENT '充值数量总计（单位：分）',
  PRIMARY KEY (`player_id`) USING BTREE,
  INDEX `index2`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家充值统计表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_pay_product_stat
-- ----------------------------
DROP TABLE IF EXISTS `player_pay_product_stat`;
CREATE TABLE `player_pay_product_stat`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id\n\n10111111111，ID由11位数字组成，前两位表示服务器号',
  `product_id` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '我们自己的商品id',
  `buy_count` int(255) NULL DEFAULT NULL COMMENT '购买次数',
  PRIMARY KEY (`player_id`, `product_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_prop
-- ----------------------------
DROP TABLE IF EXISTS `player_prop`;
CREATE TABLE `player_prop`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `prop_type` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'shop_ticket' COMMENT '道具类型。目前只有  shop_ticket（ 购物券）',
  `prop_count` bigint(50) NULL DEFAULT 0 COMMENT '数量',
  PRIMARY KEY (`id`, `prop_type`) USING BTREE,
  INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `index3`(`prop_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家道具表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_prop_log
-- ----------------------------
DROP TABLE IF EXISTS `player_prop_log`;
CREATE TABLE `player_prop_log`  (
  `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志 id ，主键',
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `date` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  `prop_type` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '道具类型。目前只有  shop_ticket（ 购物券）',
  `change_value` bigint(20) NULL DEFAULT NULL COMMENT '变化量',
  `change_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '变化原因： weixin 微信充值； ali_pay 支付宝充值； 。。。',
  `current` bigint(50) NULL DEFAULT NULL COMMENT '变化后数量',
  `change_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '编号ID，外部数据，（如订单ID，对局ID）',
  `shop_gold_sync_seq` bigint(50) NULL DEFAULT 0 COMMENT '购物金的同步序号,供后台业务系统同步数据',
  `change_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `change_way_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `shop_gold_sync_seq`(`shop_gold_sync_seq`) USING BTREE,
  INDEX `index3`(`prop_type`) USING BTREE,
  INDEX `index4`(`change_type`) USING BTREE,
  INDEX `index5`(`change_id`) USING BTREE,
  INDEX `id`(`id`, `date`) USING BTREE,
  INDEX `PPL_date_index`(`date`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30664149 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家道具日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_prop_refund
-- ----------------------------
DROP TABLE IF EXISTS `player_prop_refund`;
CREATE TABLE `player_prop_refund`  (
  `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志 id ，主键',
  `log_id_refund` int(10) UNSIGNED NOT NULL COMMENT '退款的日志id（目前只有报名费）',
  `seq_refund` bigint(50) NULL DEFAULT 0 COMMENT '退款的同步序号',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `log_id_refund`(`log_id_refund`) USING BTREE,
  INDEX `seq_refund`(`seq_refund`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'player_prop_log 表中 的退款记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_rank_award_log
-- ----------------------------
DROP TABLE IF EXISTS `player_rank_award_log`;
CREATE TABLE `player_rank_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `rank_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '排行榜类型',
  `rank_id` int(50) NULL DEFAULT NULL COMMENT '排名',
  `stage_rank_id` int(50) NULL DEFAULT NULL COMMENT '阶段排名',
  `award_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11633 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_rank_data
-- ----------------------------
DROP TABLE IF EXISTS `player_rank_data`;
CREATE TABLE `player_rank_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `rank_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '排行榜类型',
  `score` bigint(50) NULL DEFAULT NULL COMMENT '玩家分数',
  `player_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家昵称',
  `time` bigint(50) NULL DEFAULT 0 COMMENT '上次更新时间',
  PRIMARY KEY (`player_id`, `rank_type`) USING BTREE,
  INDEX `rank_type`(`rank_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_rank_log
-- ----------------------------
DROP TABLE IF EXISTS `player_rank_log`;
CREATE TABLE `player_rank_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `player_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家昵称',
  `rank_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '排行榜类型',
  `rank` int(50) NULL DEFAULT NULL COMMENT '排名',
  `score` bigint(50) NULL DEFAULT NULL COMMENT '分数',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11648 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_register
-- ----------------------------
DROP TABLE IF EXISTS `player_register`;
CREATE TABLE `player_register`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `register_channel` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '注册渠道。 youke 游客；phone 手机号； weixin_gz 微信公众平台；weixin_kf 微信开放平台； 。。。',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'normal' COMMENT '平台标识',
  `login_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '注册渠道 提供的用户编号:电话号码，微信的unionid等',
  `introducer` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '介绍人',
  `register_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '注册时 用户设备的 ip 地址',
  `register_os` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '注册时 用户设备的 操作系统',
  `register_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '注册时间',
  `market_channel` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'normal' COMMENT '推广渠道',
  `device_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '设备id',
  `share_sources` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '用户来源  \"分享来源\"+\"_\"分享图id\"',
  `systype` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'unknown' COMMENT '操作系统类型',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `PR_market_channel_index`(`market_channel`, `register_channel`, `register_time`) USING BTREE,
  INDEX `index2`(`register_channel`, `market_channel`, `register_time`) USING BTREE,
  INDEX `PR_register_time_index`(`register_time`, `register_channel`, `market_channel`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '注册信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_sd_gift_bag_status
-- ----------------------------
DROP TABLE IF EXISTS `player_sd_gift_bag_status`;
CREATE TABLE `player_sd_gift_bag_status`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `status` tinyint(20) NULL DEFAULT 0,
  `time` date NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_shop_gold_stat
-- ----------------------------
DROP TABLE IF EXISTS `player_shop_gold_stat`;
CREATE TABLE `player_shop_gold_stat`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id\n\n10111111111，ID由11位数字组成，前两位表示服务器号',
  `dui_shiwu_gold` bigint(255) NOT NULL DEFAULT 0 COMMENT '兑换实物（线上商城）',
  `dui_jingbi_gold` bigint(255) NOT NULL DEFAULT 0 COMMENT '兑换鲸币（充值界面）',
  `dui_xiaofei_gold` bigint(255) NOT NULL DEFAULT 0 COMMENT '线下消费（线下商城）',
  PRIMARY KEY (`player_id`) USING BTREE,
  INDEX `index2`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家充值统计表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_shop_order
-- ----------------------------
DROP TABLE IF EXISTS `player_shop_order`;
CREATE TABLE `player_shop_order`  (
  `order_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '订单号',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `order_status` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'complete' COMMENT '订单状态（\"complete\" - 完成,\"refund\" - 退款）',
  `amount` bigint(11) NOT NULL DEFAULT 0 COMMENT '消费总额',
  `props_json` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '消费多个面额消费张数的json: {\"10\":2,\"30\":1}',
  `shoping_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '本次购买的描述信息，比如： 购买 xxx 商品 nnn 件。',
  `shoping_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '购物时间',
  `refund_time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '退款时间',
  `goods_id` int(11) NULL DEFAULT NULL COMMENT '商品id',
  `authflags_json` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '商品权限的json: [\"xxx\",\"xxx\",...]',
  `actual_amount` bigint(20) NULL DEFAULT NULL COMMENT '商品的实际价值，用于web端统计用',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `order_id_UNIQUE`(`order_id`) USING BTREE,
  INDEX `index_shoping_time`(`shoping_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家商城订单表。玩家通过商城购买东西的订单。' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_shop_order_log
-- ----------------------------
DROP TABLE IF EXISTS `player_shop_order_log`;
CREATE TABLE `player_shop_order_log`  (
  `order_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '订单号',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `order_status` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'complete' COMMENT '订单状态（\"complete\" - 完成,\"refund\" - 退款）',
  `amount` bigint(11) NOT NULL DEFAULT 0 COMMENT '消费总额',
  `props_json` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '消费多个道具的json: {\"shop_gold_10\":2,\"shop_gold_100\":1}',
  `shoping_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '本次购买的描述信息，比如： 购买 xxx 商品 nnn 件。',
  `shoping_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '购物时间',
  `refund_time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '退款时间',
  `goods_id` int(11) NULL DEFAULT NULL COMMENT '商品id',
  `authflags_json` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '商品权限的json: [\"xxx\",\"xxx\",...]',
  `actual_amount` bigint(20) NULL DEFAULT NULL COMMENT '商品的实际价值，用于web端统计用',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `order_id_UNIQUE`(`order_id`) USING BTREE,
  INDEX `index_shoping_time`(`shoping_time`) USING BTREE,
  INDEX `index4`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家商城订单表。玩家通过商城购买东西的订单。' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_sign_in
-- ----------------------------
DROP TABLE IF EXISTS `player_sign_in`;
CREATE TABLE `player_sign_in`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `sign_in_day` int(11) NULL DEFAULT 0 COMMENT '签到第几天',
  `sign_in_award` tinyint(4) NULL DEFAULT 0 COMMENT '今天的签到奖励是否可领',
  `acc_day` int(11) NULL DEFAULT 0 COMMENT '累积签到几天',
  `acc_award` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '累积奖励可以领取的列表json',
  `sign_in_last_time` bigint(20) NULL DEFAULT 0 COMMENT '上次签到的时间戳',
  `acc_cur_time` bigint(20) NULL DEFAULT 0 COMMENT '累积签到的时间戳',
  PRIMARY KEY (`player_id`) USING BTREE,
  INDEX `name`(`sign_in_day`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_sign_in_log
-- ----------------------------
DROP TABLE IF EXISTS `player_sign_in_log`;
CREATE TABLE `player_sign_in_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `opt` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作',
  `data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '数据',
  `time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `name`(`opt`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2214447 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_statis_profit_log
-- ----------------------------
DROP TABLE IF EXISTS `player_statis_profit_log`;
CREATE TABLE `player_statis_profit_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `yestoday_profit` bigint(50) NULL DEFAULT NULL COMMENT '昨日的盈亏',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '记录的时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5010776 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_stepstep_money
-- ----------------------------
DROP TABLE IF EXISTS `player_stepstep_money`;
CREATE TABLE `player_stepstep_money`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `now_big_step` tinyint(10) NULL DEFAULT NULL COMMENT '所在的大步骤',
  `now_little_step` tinyint(10) NULL DEFAULT NULL COMMENT '所在的小步骤',
  `last_op_time` bigint(50) NULL DEFAULT NULL COMMENT '最后操作的时间',
  `can_do_big_step` tinyint(10) NULL DEFAULT NULL COMMENT '可以做的大步骤',
  `bbsc_version` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'old' COMMENT 'bbsc的版本new或old',
  `over_time` bigint(50) NULL DEFAULT NULL COMMENT '过期时间，具体时间戳',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_tag
-- ----------------------------
DROP TABLE IF EXISTS `player_tag`;
CREATE TABLE `player_tag`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id\n\n10111111111，ID由11位数字组成，前两位表示服务器号',
  `tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标签名/类型名',
  `is_type` int(11) NULL DEFAULT 0 COMMENT '0 标签；1 类型',
  `value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '当前值：标签 y 有；n 无；类型：标签名（空串 null 表示无）',
  `period` int(11) NULL DEFAULT 0 COMMENT '更新周期：0 手动更新，1 小时，2 天，3 周',
  `time` int(11) NULL DEFAULT 0 COMMENT '上次更新时间戳',
  PRIMARY KEY (`player_id`, `tag`) USING BTREE,
  INDEX `period`(`period`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家标签表，存放非即时运算的标签' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_task
-- ----------------------------
DROP TABLE IF EXISTS `player_task`;
CREATE TABLE `player_task`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `task_id` int(20) NOT NULL DEFAULT 0,
  `process` bigint(50) NULL DEFAULT 0,
  `task_round` int(20) NULL DEFAULT 1 COMMENT '当前进行的任务次数，该领取的任务等级',
  `create_time` bigint(50) NULL DEFAULT NULL,
  `time_limit` bigint(50) NULL DEFAULT NULL COMMENT '任务有效期时间点',
  `task_award_get_status` bigint(50) NULL DEFAULT 0 COMMENT '任务奖励的领取状态',
  `other_data` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '任务其他数据',
  PRIMARY KEY (`player_id`, `task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_task_award_log
-- ----------------------------
DROP TABLE IF EXISTS `player_task_award_log`;
CREATE TABLE `player_task_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `task_id` mediumint(30) NULL DEFAULT NULL COMMENT '任务id',
  `award_progress_lv` smallint(20) NULL DEFAULT NULL COMMENT '奖励的进程id',
  `award_asset_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励的资产类型',
  `award_asset_value` int(50) NULL DEFAULT NULL COMMENT '奖励的资产值',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `PTAL_time_INDEX`(`time`) USING BTREE,
  INDEX `PTAL_taskid_INDEX`(`task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5972860 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_task_log
-- ----------------------------
DROP TABLE IF EXISTS `player_task_log`;
CREATE TABLE `player_task_log`  (
  `id` int(20) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `task_id` int(20) NULL DEFAULT NULL COMMENT '任务id',
  `progress_change` int(20) NULL DEFAULT NULL COMMENT '任务进度改变值',
  `now_progress` bigint(20) NULL DEFAULT NULL COMMENT '当前进度值',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '当前的记录时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `player_id`(`player_id`) USING BTREE,
  INDEX `task_id`(`task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 236388282 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_task_switch
-- ----------------------------
DROP TABLE IF EXISTS `player_task_switch`;
CREATE TABLE `player_task_switch`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `task_id` int(50) NOT NULL COMMENT '精准的任务id',
  `is_enable` tinyint(10) NULL DEFAULT NULL COMMENT '是否启用,0=false , 1=true',
  PRIMARY KEY (`player_id`, `task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_ticket
-- ----------------------------
DROP TABLE IF EXISTS `player_ticket`;
CREATE TABLE `player_ticket`  (
  `id` int(50) UNSIGNED NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'shop_ticket' COMMENT '道具类型。目前只有  shop_ticket（ 购物券）',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0',
  `num` int(20) UNSIGNED NULL DEFAULT NULL,
  `valid_time` bigint(20) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `index3`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家道具表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_ticket_log
-- ----------------------------
DROP TABLE IF EXISTS `player_ticket_log`;
CREATE TABLE `player_ticket_log`  (
  `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志 id ，主键',
  `id` int(50) UNSIGNED NULL DEFAULT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'shop_ticket' COMMENT '道具类型。目前只有  shop_ticket（ 购物券）',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0',
  `num` int(20) NULL DEFAULT NULL,
  `final_num` int(20) UNSIGNED NULL DEFAULT NULL,
  `valid_time` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `change_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `date` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  `comment` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家道具日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_variant
-- ----------------------------
DROP TABLE IF EXISTS `player_variant`;
CREATE TABLE `player_variant`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id\n\n10111111111，ID由11位数字组成，前两位表示服务器号',
  `orig_variant` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '原始变量名',
  `str_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '字符串值',
  `int_value` bigint(20) NULL DEFAULT NULL COMMENT '整数值',
  PRIMARY KEY (`player_id`, `orig_variant`) USING BTREE,
  INDEX `index2`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家原始变量表（用于计算 变量，作为条件、标签的依据）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_verify
-- ----------------------------
DROP TABLE IF EXISTS `player_verify`;
CREATE TABLE `player_verify`  (
  `login_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录id，电话号码，微信的unionid等',
  `channel_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录渠道类型。 youke 游客；phone 手机号； weixin_gz 微信公众平台；weixin_kf 微信开放平台；。。。',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'normal' COMMENT '平台标识',
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `refresh_token` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `extend_1` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '其他 id。 某些登录渠道可能有 额外的id，例如微信的 unionid',
  `extend_2` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`login_id`, `channel_type`, `platform`) USING BTREE,
  INDEX `index2`(`id`) USING BTREE,
  INDEX `index3`(`extend_1`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '登录验证表\n' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_verify_log
-- ----------------------------
DROP TABLE IF EXISTS `player_verify_log`;
CREATE TABLE `player_verify_log`  (
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增 id',
  `op` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '操作类型： add, del',
  `note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注，记录此次操作的说明',
  `date` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '操作时间',
  `login_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录id，电话号码，微信的unionid等',
  `channel_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录渠道类型。 youke 游客；phone 手机号； weixin_gz 微信公众平台；weixin_kf 微信开放平台；。。。',
  `platform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'normal' COMMENT '平台标识',
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `refresh_token` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `extend_1` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '其他 id。 某些登录渠道可能有 额外的id，例如微信的 unionid',
  `extend_2` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `index2`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40266 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '登录验证日志表： 删除、启用验证信息的 日志\r\n' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_vip
-- ----------------------------
DROP TABLE IF EXISTS `player_vip`;
CREATE TABLE `player_vip`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `vip_time` bigint(50) NULL DEFAULT NULL COMMENT 'vip到期的时间(时间戳)',
  `vip_day_time` int(10) NULL DEFAULT NULL COMMENT '剩余的vip的天数',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_vip_buy_record
-- ----------------------------
DROP TABLE IF EXISTS `player_vip_buy_record`;
CREATE TABLE `player_vip_buy_record`  (
  `id` int(20) NOT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '购买 vip 的玩家',
  `payback_player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '获得 FL 的玩家',
  `payback_value` int(20) NULL DEFAULT NULL COMMENT 'FL金额',
  `buy_vip_day` int(10) NULL DEFAULT NULL COMMENT '购买的vip的天数',
  `buy_time` bigint(50) NULL DEFAULT NULL COMMENT '购买vip日期',
  `buy_time_year` mediumint(20) NULL DEFAULT NULL COMMENT '购买vip日期_年',
  `buy_time_month` tinyint(20) NULL DEFAULT NULL COMMENT '购买vip日期_月',
  `buy_time_day` tinyint(20) NULL DEFAULT NULL COMMENT '购买vip日期_日',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_vip_generalize
-- ----------------------------
DROP TABLE IF EXISTS `player_vip_generalize`;
CREATE TABLE `player_vip_generalize`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `award_value` int(50) NULL DEFAULT NULL COMMENT '推广奖励值，可领取的',
  `today_get_award` int(50) NULL DEFAULT NULL COMMENT '今日已经领取的奖励值',
  `last_get_time` bigint(50) NULL DEFAULT NULL COMMENT '上次领取的时间',
  `total_award_value` int(50) NULL DEFAULT NULL COMMENT '总共获得的推广奖励(领取了和未领取的)',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_vip_generalize_extract_record
-- ----------------------------
DROP TABLE IF EXISTS `player_vip_generalize_extract_record`;
CREATE TABLE `player_vip_generalize_extract_record`  (
  `id` int(20) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `extract_value` int(20) NULL DEFAULT NULL COMMENT '提取值',
  `extract_time` bigint(50) NULL DEFAULT NULL COMMENT '日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_vip_reward_task
-- ----------------------------
DROP TABLE IF EXISTS `player_vip_reward_task`;
CREATE TABLE `player_vip_reward_task`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `reward_task_status` tinyint(20) NULL DEFAULT NULL COMMENT '0是未完成，1是完成了未领取，2是领取了',
  `last_op_time` bigint(50) NULL DEFAULT NULL COMMENT '上次操作的时间',
  `award_value` int(11) NULL DEFAULT NULL COMMENT '奖励值的多少(当日返奖任务的奖励值)',
  `total_get_award` int(50) NULL DEFAULT NULL COMMENT '总共已经获取到的奖励值，不能领的',
  `total_find_award` int(50) NULL DEFAULT NULL COMMENT '总共找回的奖励值,还可以领取的',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家vip返奖任务，(对局红包任务)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_vip_reward_task_record
-- ----------------------------
DROP TABLE IF EXISTS `player_vip_reward_task_record`;
CREATE TABLE `player_vip_reward_task_record`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `get_award_value` int(50) NULL DEFAULT NULL COMMENT '当日领取或找回的奖励值;或领取的找回的奖励值',
  `status` tinyint(10) NULL DEFAULT NULL COMMENT '当日的任务状态, 0 表示未完成；1完成了系统帮领；2完成并领取了；3领取了帮领(找回)的奖励',
  `time` bigint(50) NULL DEFAULT NULL COMMENT '任务结算的时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = 'vip返奖任务的每日记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_watermelon_rank_data
-- ----------------------------
DROP TABLE IF EXISTS `player_watermelon_rank_data`;
CREATE TABLE `player_watermelon_rank_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `total_watermelon` int(50) NULL DEFAULT NULL COMMENT '总共累积的西瓜数量',
  `player_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家昵称',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_withdraw
-- ----------------------------
DROP TABLE IF EXISTS `player_withdraw`;
CREATE TABLE `player_withdraw`  (
  `withdraw_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `withdraw_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态（init,create,error,fail,complete）',
  `error_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `money` int(11) NOT NULL DEFAULT 0 COMMENT '提现金额（单位：分）',
  `src_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源类型。game 游戏中提现； gjhhr_ht 高级合伙人后台提现',
  `asset_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '财富类型',
  `channel_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收款渠道',
  `channel_withdraw_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道方的交易id',
  `channel_receiver_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道收款方id',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `complete_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '完成时间',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`withdraw_id`) USING BTREE,
  INDEX `index2`(`complete_time`, `withdraw_status`) USING BTREE,
  INDEX `plwd_playerid_index`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '玩家提现表（玩家提取现金）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_withdraw_log
-- ----------------------------
DROP TABLE IF EXISTS `player_withdraw_log`;
CREATE TABLE `player_withdraw_log`  (
  `withdraw_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `withdraw_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态（init,error,fail,complete）',
  `error_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `money` int(11) NOT NULL DEFAULT 0 COMMENT '提现金额（单位：分）',
  `src_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源类型。game 游戏中提现； gjhhr_ht 高级合伙人后台提现',
  `asset_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '财富类型',
  `channel_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收款渠道',
  `channel_withdraw_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道方的交易id',
  `channel_receiver_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道收款方id',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `complete_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '完成时间',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`withdraw_id`) USING BTREE,
  INDEX `plwdlog_playerid_index`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '玩家提现表（玩家提取现金）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_withdraw_shop_gold
-- ----------------------------
DROP TABLE IF EXISTS `player_withdraw_shop_gold`;
CREATE TABLE `player_withdraw_shop_gold`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `money` int(50) NULL DEFAULT NULL COMMENT '消耗的提现金额',
  `shop_gold_sum` int(50) NULL DEFAULT NULL COMMENT '提成红包劵的个数',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '完成时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1307 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_withdraw_status
-- ----------------------------
DROP TABLE IF EXISTS `player_withdraw_status`;
CREATE TABLE `player_withdraw_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `opt_time` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '每天第一次操作时间',
  `withdraw_num` tinyint(20) UNSIGNED NULL DEFAULT 0 COMMENT '提现次数',
  `withdraw_money` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '提现金额',
  PRIMARY KEY (`player_id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '玩家财物表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_withdraw_task_status
-- ----------------------------
DROP TABLE IF EXISTS `player_withdraw_task_status`;
CREATE TABLE `player_withdraw_task_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `opt_time` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '每天第一次操作时间',
  `withdraw_num` tinyint(20) UNSIGNED NULL DEFAULT 0 COMMENT '提现次数',
  `withdraw_money` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '提现金额',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xiaoxiaole_caishen_log
-- ----------------------------
DROP TABLE IF EXISTS `player_xiaoxiaole_caishen_log`;
CREATE TABLE `player_xiaoxiaole_caishen_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `total_bet_money` int(50) NULL DEFAULT NULL COMMENT '总竞猜金额',
  `bet_money` int(50) NULL DEFAULT NULL COMMENT '竞猜的单线总金额',
  `kaijiang_beishu` float(50, 2) NULL DEFAULT NULL COMMENT '开奖的总倍数(未乘10的原始单线倍数)',
  `kaijiang_award` int(50) NULL DEFAULT NULL COMMENT '开奖奖励金额(直接给的部分，不含进度条的部分)',
  `config_version` smallint(50) NULL DEFAULT NULL COMMENT '配置的版本号(最大32767)',
  `all_rate` int(50) NULL DEFAULT NULL COMMENT '总倍数(*10的,即生成数据中的单线倍数，包含了进度条的增加倍数 )',
  `jindan_progress_extra_rate` int(50) NULL DEFAULT NULL COMMENT '金蛋进度条的额外倍数（*10）',
  `jindan_progress_add_value` int(50) NULL DEFAULT NULL COMMENT '金蛋进度条的增加值',
  `sky_girl_type` tinyint(10) NULL DEFAULT NULL COMMENT '天女散花类型(最大127)',
  `cfg_pos_index` mediumint(50) NULL DEFAULT NULL COMMENT '天女散花下的索引位置(最大8388607)',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '开奖类型',
  `kaijiang_index` mediumint(50) NULL DEFAULT NULL COMMENT '开奖索引',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开奖时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 238963 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xiaoxiaole_caishen_progress_data
-- ----------------------------
DROP TABLE IF EXISTS `player_xiaoxiaole_caishen_progress_data`;
CREATE TABLE `player_xiaoxiaole_caishen_progress_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `jindan_progress_value` int(50) NULL DEFAULT NULL COMMENT '金蛋进度条价值',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xiaoxiaole_log
-- ----------------------------
DROP TABLE IF EXISTS `player_xiaoxiaole_log`;
CREATE TABLE `player_xiaoxiaole_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `total_bet_money` int(50) NULL DEFAULT NULL COMMENT '总竞猜金额',
  `bet_money` int(50) NULL DEFAULT NULL COMMENT '竞猜的总金额',
  `kaijiang_beishu` float(50, 2) NULL DEFAULT NULL COMMENT '开奖的总倍数',
  `kaijiang_award` int(50) NULL DEFAULT NULL COMMENT '开奖奖励金额',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  `orig_xc_str` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '原始开奖字符串',
  `final_xc_str` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '最终字符串',
  `lucky_str` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'lucky字符串',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 57672335 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xiaoxiaole_shuihu_log
-- ----------------------------
DROP TABLE IF EXISTS `player_xiaoxiaole_shuihu_log`;
CREATE TABLE `player_xiaoxiaole_shuihu_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `total_bet_money` int(50) NULL DEFAULT NULL COMMENT '总竞猜金额',
  `bet_money` int(50) NULL DEFAULT NULL COMMENT '竞猜的总金额',
  `kaijiang_beishu` float(50, 2) NULL DEFAULT NULL COMMENT '开奖的总倍数',
  `kaijiang_award` int(50) NULL DEFAULT NULL COMMENT '开奖奖励金额',
  `config_version` smallint(50) NULL DEFAULT NULL COMMENT '配置的版本号(最大32767)',
  `all_rate` int(50) NULL DEFAULT NULL COMMENT '总倍数',
  `hero_num` tinyint(10) NULL DEFAULT NULL COMMENT '英雄个数(最大127)',
  `cfg_pos_index` mediumint(50) NULL DEFAULT NULL COMMENT '英雄下的索引位置(最大8388607)',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `player_id_idx`(`player_id`) USING BTREE,
  INDEX `time`(`time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 33616640 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xsyd_status
-- ----------------------------
DROP TABLE IF EXISTS `player_xsyd_status`;
CREATE TABLE `player_xsyd_status`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` tinyint(4) NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xuyuanchi_award_log
-- ----------------------------
DROP TABLE IF EXISTS `player_xuyuanchi_award_log`;
CREATE TABLE `player_xuyuanchi_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `award_id` mediumint(30) NULL DEFAULT NULL COMMENT '奖励id',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `award_jingbi_value` int(50) NULL DEFAULT NULL COMMENT '等价值的鲸币数',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 489826 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xuyuanchi_data
-- ----------------------------
DROP TABLE IF EXISTS `player_xuyuanchi_data`;
CREATE TABLE `player_xuyuanchi_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `is_vow` tinyint(10) NULL DEFAULT NULL COMMENT '是否许愿',
  `last_vow_time` bigint(50) NULL DEFAULT NULL COMMENT '上次许愿的时间',
  `get_award_num` int(50) NULL DEFAULT NULL COMMENT '获得奖励的次数',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xuyuanchi_log
-- ----------------------------
DROP TABLE IF EXISTS `player_xuyuanchi_log`;
CREATE TABLE `player_xuyuanchi_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `vow_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '许愿日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 80993 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xuyuanchi_sys_data
-- ----------------------------
DROP TABLE IF EXISTS `player_xuyuanchi_sys_data`;
CREATE TABLE `player_xuyuanchi_sys_data`  (
  `today_xuyuan_num` int(50) NULL DEFAULT 0 COMMENT '今日许愿人数',
  `fork_xuyuan_num` int(50) NULL DEFAULT 0 COMMENT '假的许愿人数',
  `last_xuyuan_time` bigint(50) NULL DEFAULT 0 COMMENT '最后一次许愿的时间'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_xuyuanchi_sys_log
-- ----------------------------
DROP TABLE IF EXISTS `player_xuyuanchi_sys_log`;
CREATE TABLE `player_xuyuanchi_sys_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `today_xuyuan_num` int(50) NULL DEFAULT NULL COMMENT '总共的许愿人数',
  `fork_xuyuan_num` int(50) NULL DEFAULT NULL COMMENT '假的许愿人数',
  `last_xuyuan_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '记录的时间(这里记的是前一天的数据)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 226 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_yueka_data
-- ----------------------------
DROP TABLE IF EXISTS `player_yueka_data`;
CREATE TABLE `player_yueka_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `is_buy_yueka1` tinyint(10) NULL DEFAULT NULL COMMENT '是否购买月卡1',
  `is_buy_yueka2` tinyint(10) NULL DEFAULT NULL COMMENT '是否购买月卡2',
  `buy_time` bigint(50) NULL DEFAULT NULL COMMENT '购买时间',
  `task_over_time` int(50) NULL DEFAULT NULL COMMENT '任务过期时间',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_zajindan_info
-- ----------------------------
DROP TABLE IF EXISTS `player_zajindan_info`;
CREATE TABLE `player_zajindan_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `today_get_award` int(50) NULL DEFAULT NULL COMMENT '今日获得的奖励',
  `today_id` int(50) NULL DEFAULT NULL COMMENT '今天的id，具体是距离某一天的多少天',
  `today_get_biggest_award_num_1` int(50) NULL DEFAULT 0 COMMENT '今天获得的第一个砸金蛋场的最大奖励的数量',
  `today_get_biggest_award_num_2` int(50) NULL DEFAULT 0 COMMENT '今天获得的第二个砸金蛋场的最大奖励的数量',
  `today_get_biggest_award_num_3` int(50) NULL DEFAULT 0 COMMENT '今天获得的第三个砸金蛋场的最大奖励的数量',
  `today_get_biggest_award_num_4` int(50) NULL DEFAULT 0 COMMENT '今天获得的第四个砸金蛋场的最大奖励的数量',
  `last_game_remain_eggs1` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '锤子1，上次游戏剩下的蛋(直接保存数据)',
  `last_game_remain_eggs2` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '锤子2，上次游戏剩下的蛋(直接保存数据)',
  `last_game_remain_eggs3` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '锤子3，上次游戏剩下的蛋(直接保存数据)',
  `last_game_remain_eggs4` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '锤子4，上次游戏剩下的蛋(直接保存数据)',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_zajindan_log
-- ----------------------------
DROP TABLE IF EXISTS `player_zajindan_log`;
CREATE TABLE `player_zajindan_log`  (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `round_id` int(50) NULL DEFAULT NULL COMMENT '轮数',
  `hammer_id` tinyint(10) NULL DEFAULT NULL COMMENT '锤子id',
  `egg_no` tinyint(20) NULL DEFAULT NULL COMMENT '砸的蛋的id',
  `award_id` tinyint(20) NULL DEFAULT NULL COMMENT '奖励id',
  `award_type` tinyint(10) NULL DEFAULT NULL COMMENT '奖励类型',
  `award_value` int(50) NULL DEFAULT NULL COMMENT '奖励值',
  `award_data` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励的str,逗号分割,,奖励的翻倍数',
  `za_times` tinyint(10) NULL DEFAULT NULL COMMENT '砸这个蛋的次数',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '记录时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8612225 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_zajindan_round_log
-- ----------------------------
DROP TABLE IF EXISTS `player_zajindan_round_log`;
CREATE TABLE `player_zajindan_round_log`  (
  `id` int(50) NOT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `hammer_id` tinyint(10) NULL DEFAULT NULL COMMENT '锤子id',
  `award_data` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励string,逗号分割,,奖励的翻倍数',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for player_zhouka
-- ----------------------------
DROP TABLE IF EXISTS `player_zhouka`;
CREATE TABLE `player_zhouka`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `is_buy_jingbi_zhouka` tinyint(10) NULL DEFAULT 0 COMMENT '是否购买金币周卡',
  `jingbi_zhouka_remain` mediumint(30) NULL DEFAULT 0 COMMENT '金币周卡剩余的领取次数',
  `jingbi_zhouka_last_get_time` bigint(50) NULL DEFAULT NULL COMMENT '鲸币周卡上次获取的时间',
  `is_buy_qys_zhouka` tinyint(10) NULL DEFAULT 0 COMMENT '是否购买千元赛周卡',
  `qys_zhouka_remain` mediumint(30) NULL DEFAULT 0 COMMENT '千元赛周卡剩余的领取次数',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for prop_type
-- ----------------------------
DROP TABLE IF EXISTS `prop_type`;
CREATE TABLE `prop_type`  (
  `prop_type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '道具类型',
  `prop_group` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '道具分组，对于类似面额的道具，同属于一种',
  `value` int(11) NULL DEFAULT 1 COMMENT '道具的值，对于 面额，为实际值。默认为 1',
  PRIMARY KEY (`prop_type`) USING BTREE,
  INDEX `prop_group`(`prop_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '道具类型信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for rank_server_player_list_data
-- ----------------------------
DROP TABLE IF EXISTS `rank_server_player_list_data`;
CREATE TABLE `rank_server_player_list_data`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志 id ，主键',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `rank_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '财物类型： match_ticket, room_card,shop_gold,cash',
  `status` int(255) NULL DEFAULT NULL COMMENT '0-no 1-ok',
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `t`(`player_id`, `rank_type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for real_name_authentication
-- ----------------------------
DROP TABLE IF EXISTS `real_name_authentication`;
CREATE TABLE `real_name_authentication`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `identity_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for red_envelope_rain_award_data
-- ----------------------------
DROP TABLE IF EXISTS `red_envelope_rain_award_data`;
CREATE TABLE `red_envelope_rain_award_data`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` bigint(50) NULL DEFAULT NULL COMMENT '开始或结束发红包的时间',
  `award` bigint(50) NULL DEFAULT NULL COMMENT '红包总数',
  `complete` int(11) NULL DEFAULT NULL COMMENT '是否完成，0表示开始，1表示完成',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for redeem_code_content
-- ----------------------------
DROP TABLE IF EXISTS `redeem_code_content`;
CREATE TABLE `redeem_code_content`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `code_sub_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `key_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `used_count` int(128) NULL DEFAULT 0 COMMENT '使用了几次',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `key_code`(`key_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46128 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for redeem_code_data
-- ----------------------------
DROP TABLE IF EXISTS `redeem_code_data`;
CREATE TABLE `redeem_code_data`  (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `code_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `code_sub_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `market_channel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'normal',
  `use_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `use_args` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `start_time` bigint(20) NULL DEFAULT NULL,
  `end_time` bigint(20) NULL DEFAULT NULL,
  `register_limit_time` bigint(20) NULL DEFAULT NULL,
  `assets` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `type`(`code_type`, `code_sub_type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 73 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for redeem_code_log
-- ----------------------------
DROP TABLE IF EXISTS `redeem_code_log`;
CREATE TABLE `redeem_code_log`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `key_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `code_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `code_sub_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `market_channel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'normal',
  `comment` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `use_time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 92869 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for redeem_code_opt_log
-- ----------------------------
DROP TABLE IF EXISTS `redeem_code_opt_log`;
CREATE TABLE `redeem_code_opt_log`  (
  `id` int(255) UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `opt_time` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 60 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_achievement_error_topic_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_achievement_error_topic_log`;
CREATE TABLE `sczd_achievement_error_topic_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `test_id` int(50) NULL DEFAULT NULL COMMENT '参与测试的id',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `error_topic` tinyint(10) NULL DEFAULT NULL COMMENT '错误的题目id',
  `error_answer` tinyint(10) NULL DEFAULT NULL COMMENT '错误的答案编号',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30921 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_achievement_sys_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_achievement_sys_log`;
CREATE TABLE `sczd_achievement_sys_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id,增加成就点的玩家',
  `gx_player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '贡献成就点的玩家',
  `add_num` mediumint(30) NULL DEFAULT NULL COMMENT '增加额成就点数量',
  `reason` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '贡献原因',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 72346 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_activity_info
-- ----------------------------
DROP TABLE IF EXISTS `sczd_activity_info`;
CREATE TABLE `sczd_activity_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `tglb_contribution_for_parent` int(50) NULL DEFAULT NULL COMMENT '推广礼包给父亲贡献的值',
  `bbsc_contribution_for_parent` int(50) NULL DEFAULT NULL COMMENT '步步生财给父亲贡献的值',
  `vip_contribution_for_parent` int(50) NULL DEFAULT 0 COMMENT 'vip礼包的贡献值',
  `tglb_contribution_cache` int(50) NULL DEFAULT NULL COMMENT '我获得的推广礼包的贡献的缓存(儿子给我的)',
  `bbsc_contribution_cache` int(50) NULL DEFAULT NULL COMMENT '我获得的步步生财的贡献的缓存(儿子给我的)',
  `qys_contribution_cache_for_parent` int(50) NULL DEFAULT 0 COMMENT '我对上级的qys的返利的缓存',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_all_return_lb_base_info
-- ----------------------------
DROP TABLE IF EXISTS `sczd_all_return_lb_base_info`;
CREATE TABLE `sczd_all_return_lb_base_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `xj_rebate_1` int(50) NULL DEFAULT NULL COMMENT '自己做全返礼包1的现金返利',
  `xj_rebate_2` int(50) NULL DEFAULT NULL COMMENT '自己做全返礼包2 的现金返利',
  `xj_rebate_3` int(50) NULL DEFAULT NULL COMMENT '自己做全返礼包3 的现金返利',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_all_return_lb_data
-- ----------------------------
DROP TABLE IF EXISTS `sczd_all_return_lb_data`;
CREATE TABLE `sczd_all_return_lb_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `all_return_bag_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '全返礼包类型',
  `is_buy` tinyint(10) NULL DEFAULT NULL COMMENT '是否购买全返礼包',
  `remain_num` mediumint(30) NULL DEFAULT NULL COMMENT '全返礼包任务剩余次数',
  `buy_time` datetime(0) NULL DEFAULT NULL COMMENT '购买时间',
  `over_time` datetime(0) NULL DEFAULT NULL COMMENT '过期时间',
  `is_send_over_email` tinyint(10) NULL DEFAULT 0 COMMENT '是否发送过期邮件',
  PRIMARY KEY (`player_id`, `all_return_bag_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_change_parent_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_change_parent_log`;
CREATE TABLE `sczd_change_parent_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `old_parent` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `new_parent` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `achievements` bigint(20) NULL DEFAULT NULL,
  `tuikuan` bigint(20) NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 742665 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_gjhhr_info
-- ----------------------------
DROP TABLE IF EXISTS `sczd_gjhhr_info`;
CREATE TABLE `sczd_gjhhr_info`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `become_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_gjhhr_info_change_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_gjhhr_info_change_log`;
CREATE TABLE `sczd_gjhhr_info_change_log`  (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `become_time` datetime(0) NULL DEFAULT NULL,
  `op_player` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `change_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `id`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 140 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_gjhhr_info_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_gjhhr_info_log`;
CREATE TABLE `sczd_gjhhr_info_log`  (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `become_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_gjhhr_rebate_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_gjhhr_rebate_log`;
CREATE TABLE `sczd_gjhhr_rebate_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gjhhr_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '高级合伙人id',
  `cycle_achievements` bigint(50) NULL DEFAULT NULL,
  `award_value` int(50) NULL DEFAULT NULL COMMENT '获得的奖励值',
  `time` bigint(50) NULL DEFAULT NULL COMMENT '获得的时间',
  `cycle_days` int(11) NULL DEFAULT NULL,
  `cycle_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_gjhhr_settle_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_gjhhr_settle_log`;
CREATE TABLE `sczd_gjhhr_settle_log`  (
  `no` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `achievements` bigint(20) NULL DEFAULT NULL,
  `tuikuan` bigint(20) NULL DEFAULT NULL,
  `income` bigint(20) NULL DEFAULT NULL,
  `my_income` bigint(20) NULL DEFAULT NULL,
  `percentage` float NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`no`) USING BTREE,
  INDEX `id`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1322 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_gjhhr_ticheng_cfg
-- ----------------------------
DROP TABLE IF EXISTS `sczd_gjhhr_ticheng_cfg`;
CREATE TABLE `sczd_gjhhr_ticheng_cfg`  (
  `id` int(11) NOT NULL,
  `achievements` bigint(20) NULL DEFAULT NULL,
  `proportion` float NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_income_deatails_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_income_deatails_log`;
CREATE TABLE `sczd_income_deatails_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `parent_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父亲节点',
  `treasure_type` mediumint(10) NULL DEFAULT NULL COMMENT '产生财富的原因类型(是步步生财的第n天还是推广礼包)',
  `treasure_value` int(50) NULL DEFAULT NULL COMMENT '财富值',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '产生时间',
  `is_active` tinyint(10) NULL DEFAULT NULL COMMENT '是否激活，1=true,0=false',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `player_id`(`player_id`) USING BTREE,
  INDEX `parent_id`(`parent_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 121543 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_player_all_achievements
-- ----------------------------
DROP TABLE IF EXISTS `sczd_player_all_achievements`;
CREATE TABLE `sczd_player_all_achievements`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `all_achievements` bigint(50) NULL DEFAULT NULL,
  `yesterday_all_achievements` bigint(50) NULL DEFAULT NULL COMMENT '获得的时间',
  `tuikuan` int(11) NULL DEFAULT NULL,
  `yesterday_tuikuan` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_player_base_info
-- ----------------------------
DROP TABLE IF EXISTS `sczd_player_base_info`;
CREATE TABLE `sczd_player_base_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `total_get_award` int(20) NULL DEFAULT NULL COMMENT '总共获得的奖励值',
  `is_activate_bbsc_profit` tinyint(10) NULL DEFAULT 1 COMMENT '是否激活bbsc收益，1 = true,0 = false',
  `is_activate_xj_profit` tinyint(1) NULL DEFAULT 0 COMMENT '是否激活下级玩家奖，下级完成bbsc第有效天的返奖',
  `is_activate_xj_profit2` tinyint(10) NULL DEFAULT NULL COMMENT '玩家奖第二个等级权限',
  `is_activate_xj_profit3` tinyint(10) NULL DEFAULT NULL COMMENT '玩家奖第三个等级权限',
  `is_activate_tglb_profit` tinyint(10) NULL DEFAULT 0 COMMENT '是否激活tglb返利收益, 1 = true',
  `is_activate_tglb_cache` tinyint(10) NULL DEFAULT 0 COMMENT '是否激活下级推广礼包缓存',
  `is_activate_tgy_tx_profit` tinyint(10) NULL DEFAULT 1 COMMENT '是否激活推广员提现,默认开启',
  `is_activate_bisai_profit` tinyint(10) NULL DEFAULT 0 COMMENT '是否激活比赛奖',
  `total_contribution_for_parent` int(50) NULL DEFAULT NULL COMMENT '我对邀请人的总贡献值',
  `all_son_count` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_player_day_achievements_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_player_day_achievements_log`;
CREATE TABLE `sczd_player_day_achievements_log`  (
  `no` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `achievements` bigint(20) NULL DEFAULT NULL,
  `tuikuan` bigint(20) NULL DEFAULT NULL,
  `all_achievements` bigint(20) NULL DEFAULT NULL,
  `all_tuikuan` bigint(20) NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`no`) USING BTREE,
  INDEX `id`(`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 679657 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_profit_change_log
-- ----------------------------
DROP TABLE IF EXISTS `sczd_profit_change_log`;
CREATE TABLE `sczd_profit_change_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `is_activate_xj_profit` tinyint(10) NULL DEFAULT NULL COMMENT '玩家奖',
  `is_activate_xj_profit2` tinyint(10) NULL DEFAULT NULL COMMENT '玩家奖2级权限',
  `is_activate_xj_profit3` tinyint(10) NULL DEFAULT NULL COMMENT '玩家奖3级权限',
  `is_activate_tglb_profit` tinyint(10) NULL DEFAULT NULL COMMENT '礼包奖',
  `is_activate_bisai_profit` tinyint(10) NULL DEFAULT NULL COMMENT '比赛奖',
  `is_activate_tgy_tx_profit` tinyint(10) NULL DEFAULT NULL COMMENT '推广员提现',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5044 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_relation_chg_plan
-- ----------------------------
DROP TABLE IF EXISTS `sczd_relation_chg_plan`;
CREATE TABLE `sczd_relation_chg_plan`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户id',
  `parent_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '上级玩家id。 null 表示不改变',
  `is_gjhhr` tinyint(11) NULL DEFAULT NULL COMMENT '是否代理。 null 不改变,1 是； 0 否。',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '加入时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `parent_id`(`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_relation_data
-- ----------------------------
DROP TABLE IF EXISTS `sczd_relation_data`;
CREATE TABLE `sczd_relation_data`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户id',
  `parent_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '上级玩家id',
  `is_tgy` tinyint(11) NULL DEFAULT 0 COMMENT '是否推广员。 1 是； 0 否。',
  `is_gjhhr` tinyint(11) NULL DEFAULT 0 COMMENT '是否代理。 1 是； 0 否。',
  `son_count` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `parent_id`(`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '俱乐部 ，或者叫：分销系统/牌友圈/推广系统' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_sys_base_info
-- ----------------------------
DROP TABLE IF EXISTS `sczd_sys_base_info`;
CREATE TABLE `sczd_sys_base_info`  (
  `total_rebate_fork_value` int(50) NULL DEFAULT 0 COMMENT '全局返奖的假数据'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sczd_vip_lb_info
-- ----------------------------
DROP TABLE IF EXISTS `sczd_vip_lb_info`;
CREATE TABLE `sczd_vip_lb_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `is_buy_vip_lb` tinyint(10) NULL DEFAULT 0 COMMENT '是否购买vip礼包',
  `now_vip_task_get_num1` tinyint(10) NULL DEFAULT 0 COMMENT '1号vip任务当前领取的次数',
  `now_vip_task_max_num1` tinyint(10) NULL DEFAULT 0 COMMENT '1号vip任务最大的领取次数',
  `now_vip_task_get_num2` tinyint(10) NULL DEFAULT 0 COMMENT '2号vip任务当前领取的次数',
  `now_vip_task_max_num2` tinyint(10) NULL DEFAULT 0 COMMENT '2号vip任务最大的领取次数',
  `now_vip_rebate_xj_num` smallint(20) NULL DEFAULT 0 COMMENT '当前vip礼包返利的下级人数',
  `max_vip_rebate_xj_num` smallint(20) NULL DEFAULT 0 COMMENT '最大的vip礼包下级返利人数',
  `task_overdue_time` bigint(50) NULL DEFAULT 0 COMMENT '任务过期时间',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for shipping_address
-- ----------------------------
DROP TABLE IF EXISTS `shipping_address`;
CREATE TABLE `shipping_address`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `phone_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_buried_point
-- ----------------------------
DROP TABLE IF EXISTS `statistics_buried_point`;
CREATE TABLE `statistics_buried_point`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '类型',
  `content` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '内容',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 501743 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_buried_point_ad_everyday_log
-- ----------------------------
DROP TABLE IF EXISTS `statistics_buried_point_ad_everyday_log`;
CREATE TABLE `statistics_buried_point_ad_everyday_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `ad_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '广告点',
  `trigger_num` int(50) NULL DEFAULT NULL COMMENT '触发次数',
  `trigger_player_num` int(50) NULL DEFAULT NULL COMMENT '触发的玩家个数(去重了的)',
  `watch_num` int(50) NULL DEFAULT NULL COMMENT '观看次数',
  `watch_player_num` int(50) NULL DEFAULT NULL COMMENT '观看的玩家个数(去重了的)',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 135 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_buried_point_log
-- ----------------------------
DROP TABLE IF EXISTS `statistics_buried_point_log`;
CREATE TABLE `statistics_buried_point_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '类型',
  `content` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '内容',
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 655351 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_everyday_lose
-- ----------------------------
DROP TABLE IF EXISTS `statistics_everyday_lose`;
CREATE TABLE `statistics_everyday_lose`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `total_lose_jingbi` bigint(50) NULL DEFAULT NULL COMMENT '每日总共的损失鲸币',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '损失的日期的统计时间(为损失的后一天)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_ddz_win
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_ddz_win`;
CREATE TABLE `statistics_player_ddz_win`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `dizhu_win_count` int(20) NULL DEFAULT 0 COMMENT '地主胜利',
  `nongmin_win_count` int(20) NULL DEFAULT 0 COMMENT '胜利',
  `defeated_count` int(20) NULL DEFAULT 0 COMMENT '失败',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_freestyle_mjxl
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_freestyle_mjxl`;
CREATE TABLE `statistics_player_freestyle_mjxl`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `win_count` int(20) NULL DEFAULT 0 COMMENT '胜利',
  `defeated_count` int(20) NULL DEFAULT 0 COMMENT '失败',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_freestyle_tyddz
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_freestyle_tyddz`;
CREATE TABLE `statistics_player_freestyle_tyddz`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `dizhu_win_count` int(20) NULL DEFAULT 0 COMMENT '地主胜利',
  `nongmin_win_count` int(20) NULL DEFAULT 0 COMMENT '胜利',
  `defeated_count` int(20) NULL DEFAULT 0 COMMENT '失败',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_game_info
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_game_info`;
CREATE TABLE `statistics_player_game_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `join_qys_num` int(50) NULL DEFAULT NULL COMMENT '参加千元赛的次数',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_leijiyingjin_data
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_leijiyingjin_data`;
CREATE TABLE `statistics_player_leijiyingjin_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `sh_xxl_award` bigint(50) NULL DEFAULT 0 COMMENT '水浒消消乐累积赢金',
  `xxl_award` bigint(50) NULL DEFAULT 0 COMMENT '消消乐累积赢金',
  `cs_xxl_award` bigint(50) NULL DEFAULT 0 COMMENT '财神消消乐累积赢金',
  `buyu_award` bigint(50) NULL DEFAULT 0 COMMENT '捕鱼',
  `bykp_award` bigint(50) NULL DEFAULT 0 COMMENT '捕鱼快跑(疯狂捕鱼)',
  `zajindan_award` bigint(50) NULL DEFAULT 0 COMMENT '砸金蛋',
  `lhd_award` bigint(50) NULL DEFAULT 0 COMMENT '龙虎斗累积赢金',
  `freestyle_game_award` bigint(50) NULL DEFAULT 0 COMMENT '自由场赢金',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_leijiyingjin_log
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_leijiyingjin_log`;
CREATE TABLE `statistics_player_leijiyingjin_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `sh_xxl_award` bigint(50) NULL DEFAULT NULL COMMENT '水浒消消乐累积赢金',
  `xxl_award` bigint(50) NULL DEFAULT NULL COMMENT '消消乐累积赢金',
  `cs_xxl_award` bigint(50) NULL DEFAULT 0 COMMENT '财神消消乐累积赢金',
  `buyu_award` bigint(50) NULL DEFAULT NULL COMMENT '捕鱼',
  `bykp_award` bigint(50) NULL DEFAULT NULL COMMENT '捕鱼快跑(疯狂捕鱼)',
  `zajindan_award` bigint(50) NULL DEFAULT NULL COMMENT '砸金蛋',
  `freestyle_game_award` bigint(50) NULL DEFAULT NULL COMMENT '自由场赢金',
  `lhd_award` bigint(50) NULL DEFAULT 0 COMMENT '龙虎斗累积赢金',
  `total_award` bigint(50) NULL DEFAULT NULL COMMENT '总赢金',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1338334 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_match_ddz
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_match_ddz`;
CREATE TABLE `statistics_player_match_ddz`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `dizhu_win_count` int(20) NULL DEFAULT 0 COMMENT '比赛券',
  `nongmin_win_count` int(20) NULL DEFAULT 0 COMMENT '房卡',
  `defeated_count` int(20) NULL DEFAULT 0 COMMENT '房卡',
  `first` int(20) NULL DEFAULT 0 COMMENT '购物金',
  `second` int(20) NULL DEFAULT 0 COMMENT '现金',
  `third` int(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_match_detail_rank
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_match_detail_rank`;
CREATE TABLE `statistics_player_match_detail_rank`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `first` int(20) NULL DEFAULT 0,
  `second` int(20) NULL DEFAULT 0,
  `third` int(20) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `one`(`player_id`, `type`) USING BTREE,
  INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `xz`(`player_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 209910 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_match_rank
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_match_rank`;
CREATE TABLE `statistics_player_match_rank`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `first` int(20) NULL DEFAULT 0 COMMENT '购物金',
  `second` int(20) NULL DEFAULT 0 COMMENT '现金',
  `third` int(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_million_ddz
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_million_ddz`;
CREATE TABLE `statistics_player_million_ddz`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `dizhu_win_count` int(20) NULL DEFAULT 0 COMMENT '比赛券',
  `nongmin_win_count` int(20) NULL DEFAULT 0 COMMENT '房卡',
  `defeated_count` int(20) NULL DEFAULT 0 COMMENT '房卡',
  `final_win` int(20) NULL DEFAULT 0 COMMENT '购物金',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_mj_win
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_mj_win`;
CREATE TABLE `statistics_player_mj_win`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `win_count` int(20) NULL DEFAULT 0 COMMENT '胜利',
  `defeated_count` int(20) NULL DEFAULT 0 COMMENT '失败',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ID_UNIQUE`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_tag
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_tag`;
CREATE TABLE `statistics_player_tag`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `tag_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '标签名字',
  `time` bigint(50) NULL DEFAULT NULL COMMENT '上次操作的时间',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_tag_log
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_tag_log`;
CREATE TABLE `statistics_player_tag_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `tag_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '标签名字',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 390548 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_player_watch_ad
-- ----------------------------
DROP TABLE IF EXISTS `statistics_player_watch_ad`;
CREATE TABLE `statistics_player_watch_ad`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `ad_id` int(20) NULL DEFAULT NULL,
  `num` int(20) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `one`(`player_id`, `ad_id`) USING BTREE,
  INDEX `ID_UNIQUE`(`id`) USING BTREE,
  INDEX `xz`(`player_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1173341 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for statistics_system_realtime
-- ----------------------------
DROP TABLE IF EXISTS `statistics_system_realtime`;
CREATE TABLE `statistics_system_realtime`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增长编号',
  `time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '记录时间',
  `channel` varchar(45) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'youke' COMMENT '用户所属渠道',
  `player_count` int(255) UNSIGNED NOT NULL DEFAULT 0 COMMENT '在线人数',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `time`(`time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1835380 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '实时统计数据' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for system_error
-- ----------------------------
DROP TABLE IF EXISTS `system_error`;
CREATE TABLE `system_error`  (
  `error_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '错误类型',
  `error_sn` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '错误标识号，和错误类型和数据相关',
  `error_info` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '错误内容',
  PRIMARY KEY (`error_name`, `error_sn`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '数据库错误记录。通常由存储过程产生' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for system_freestyle_water_pool_data
-- ----------------------------
DROP TABLE IF EXISTS `system_freestyle_water_pool_data`;
CREATE TABLE `system_freestyle_water_pool_data`  (
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `game_id` int(11) NOT NULL,
  `value` bigint(20) NULL DEFAULT 0,
  PRIMARY KEY (`model`, `game_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for system_variant
-- ----------------------------
DROP TABLE IF EXISTS `system_variant`;
CREATE TABLE `system_variant`  (
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `descript` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`name`) USING BTREE,
  UNIQUE INDEX `name_UNIQUE`(`name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统变量，一些需要持久存放的 key - value 值' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for t_theday
-- ----------------------------
DROP TABLE IF EXISTS `t_theday`;
CREATE TABLE `t_theday`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id',
  `theday` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '日期',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ttheday_theday_unique`(`theday`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20001 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '日期表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for vip_addr_info
-- ----------------------------
DROP TABLE IF EXISTS `vip_addr_info`;
CREATE TABLE `vip_addr_info`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '10111111111，ID由11位数字组成，前两位表示服务器号',
  `vip_addr_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `vip_addr_changed` int(255) NULL DEFAULT NULL COMMENT '地址表是否改变过； 0 未改变；1改变过',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for vip_sc_buy_record
-- ----------------------------
DROP TABLE IF EXISTS `vip_sc_buy_record`;
CREATE TABLE `vip_sc_buy_record`  (
  `buy_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '订单 id ，用于标识一次购买',
  `status` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'init' COMMENT '状态。init 初始状态；cur 执行中； end 结束。',
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `buy_time` datetime(0) NULL DEFAULT NULL COMMENT '购买时间',
  `buy_vip_day` int(10) NULL DEFAULT NULL COMMENT '购买的vip的天数',
  `price` int(10) NULL DEFAULT NULL COMMENT '费用（人民币，分）',
  `fanjiang` int(10) NULL DEFAULT NULL COMMENT '费用（人民币，分）',
  `present` bigint(10) NULL DEFAULT NULL COMMENT '赠送鲸币数量',
  PRIMARY KEY (`buy_id`) USING BTREE,
  INDEX `player_id`(`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '每次 vip 购买的执行状态' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for vip_sc_data
-- ----------------------------
DROP TABLE IF EXISTS `vip_sc_data`;
CREATE TABLE `vip_sc_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `remain_vip_count` bigint(255) NOT NULL COMMENT '剩余vip次数  一次10天（暂定）',
  `vipfanjiang_debt` bigint(255) NOT NULL COMMENT 'vip返奖 剩下的vip总和  分期还账，不包括当期',
  `presented_debt` bigint(255) NULL DEFAULT NULL COMMENT '充值送金币的剩余 债务  分期还账，不包括当期',
  `status` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'init' COMMENT '状态：\"init\" 初始状态, \"run\" 执行中， \"done\" 完成',
  `cur_day_index` int(255) NULL DEFAULT 1 COMMENT '当前是第几天',
  `cur_vip_start_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '当前vip开始时间（10天）',
  `cur_debt` bigint(255) NULL DEFAULT 0 COMMENT '本期债务',
  `cur_remain_debt` bigint(255) NULL DEFAULT 0 COMMENT '本期已还的债务',
  `cur_qhtg_cost` bigint(255) NULL DEFAULT 0 COMMENT '当前强化托管的输赢情况',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '正在进行中的 vip ，一次购买为单位，包含 n 个周期，一个周期暂定 10 天' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for vip_sc_days
-- ----------------------------
DROP TABLE IF EXISTS `vip_sc_days`;
CREATE TABLE `vip_sc_days`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '玩家id',
  `day_index` int(255) NOT NULL COMMENT '天的序号',
  `today_debt` bigint(255) NULL DEFAULT 0 COMMENT '今天的总债务',
  `done_debt` bigint(255) NULL DEFAULT 0 COMMENT '债务完成量',
  `game_count` bigint(255) NULL DEFAULT 0 COMMENT '今天已经进行的游戏次数',
  `qhtg_vd` bigint(255) NULL DEFAULT 0 COMMENT '当前强化托管的输赢情况',
  `today_lucky` bigint(255) NULL DEFAULT 0 COMMENT '今天总红包量',
  `done_luck` bigint(255) NULL DEFAULT 0 COMMENT '已完成红包',
  PRIMARY KEY (`player_id`, `day_index`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for web_extend_data
-- ----------------------------
DROP TABLE IF EXISTS `web_extend_data`;
CREATE TABLE `web_extend_data`  (
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `type` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `value` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`name`, `type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'web 端存取的扩展变量' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for xiaoxiaole_once_game_award_log
-- ----------------------------
DROP TABLE IF EXISTS `xiaoxiaole_once_game_award_log`;
CREATE TABLE `xiaoxiaole_once_game_award_log`  (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '玩家id',
  `bet_money` int(50) NULL DEFAULT NULL COMMENT '下注金额',
  `award_money` int(50) NULL DEFAULT NULL COMMENT '奖励金额',
  `rank` smallint(20) NULL DEFAULT NULL COMMENT '排名',
  `award_id` smallint(20) NULL DEFAULT NULL COMMENT '奖励id',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '奖励名称',
  `appear_time` bigint(50) NULL DEFAULT 1568584800 COMMENT '这个数据出现的时间',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2601 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for xiaoxiaole_once_game_data
-- ----------------------------
DROP TABLE IF EXISTS `xiaoxiaole_once_game_data`;
CREATE TABLE `xiaoxiaole_once_game_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `bet_money` int(50) NULL DEFAULT NULL COMMENT '下注金额',
  `award_money` int(255) NULL DEFAULT NULL COMMENT '最大的开奖金额',
  `time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for xiaoxiaole_once_game_rank_data
-- ----------------------------
DROP TABLE IF EXISTS `xiaoxiaole_once_game_rank_data`;
CREATE TABLE `xiaoxiaole_once_game_rank_data`  (
  `id` int(50) NOT NULL,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `bet_money` int(50) NULL DEFAULT NULL COMMENT '下注金额',
  `award_money` int(50) NULL DEFAULT NULL COMMENT '奖励金额',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for zhounianqing_yuyue_data
-- ----------------------------
DROP TABLE IF EXISTS `zhounianqing_yuyue_data`;
CREATE TABLE `zhounianqing_yuyue_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `is_yuyue` tinyint(10) NULL DEFAULT NULL COMMENT '是否预约',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for zjd_cs_liansheng_info
-- ----------------------------
DROP TABLE IF EXISTS `zjd_cs_liansheng_info`;
CREATE TABLE `zjd_cs_liansheng_info`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `round` int(11) NULL DEFAULT NULL,
  `level` int(11) NULL DEFAULT NULL,
  `cur_ls` int(11) NULL DEFAULT NULL,
  `ls3` int(11) NULL DEFAULT NULL,
  `ls4` int(11) NULL DEFAULT NULL,
  `ls5` int(11) NULL DEFAULT NULL,
  `ls6` int(11) NULL DEFAULT NULL,
  `ls7` int(11) NULL DEFAULT NULL,
  `ls8` int(11) NULL DEFAULT NULL,
  `ls9` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 213 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for znq_jinianbi_lottery_award_log
-- ----------------------------
DROP TABLE IF EXISTS `znq_jinianbi_lottery_award_log`;
CREATE TABLE `znq_jinianbi_lottery_award_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家id',
  `period_id` int(50) NULL DEFAULT NULL COMMENT '期号',
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '奖励名称',
  `award_id` int(10) NULL DEFAULT NULL COMMENT '奖励id',
  `award_num` int(50) NULL DEFAULT NULL COMMENT '奖励份数',
  `jingbi_value` int(50) NULL DEFAULT NULL COMMENT '一个奖励价值的金币数',
  `total_jingbi_value` int(50) NULL DEFAULT NULL COMMENT '所有的价值的鲸币',
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '记录时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4155 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for znq_jinianbi_lottery_awards
-- ----------------------------
DROP TABLE IF EXISTS `znq_jinianbi_lottery_awards`;
CREATE TABLE `znq_jinianbi_lottery_awards`  (
  `pool_id` tinyint(10) NOT NULL COMMENT '奖池id（是1号奖池还是2号奖池）',
  `award_id` int(50) NOT NULL COMMENT '奖励id',
  `remain_num` int(50) NULL DEFAULT NULL COMMENT '剩余数量',
  PRIMARY KEY (`pool_id`, `award_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for znq_jinianbi_lottery_data
-- ----------------------------
DROP TABLE IF EXISTS `znq_jinianbi_lottery_data`;
CREATE TABLE `znq_jinianbi_lottery_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `ticket_num` int(10) NULL DEFAULT NULL COMMENT '奖券数量',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for znq_look_back_data
-- ----------------------------
DROP TABLE IF EXISTS `znq_look_back_data`;
CREATE TABLE `znq_look_back_data`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '玩家id',
  `is_kaijiang` int(2) NULL DEFAULT NULL COMMENT '是否领过奖，领过为1，没领为0',
  `kaijiang_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '领奖时间',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for znq_look_back_data_log
-- ----------------------------
DROP TABLE IF EXISTS `znq_look_back_data_log`;
CREATE TABLE `znq_look_back_data_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `award_id` int(11) NULL DEFAULT NULL,
  `award_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6185 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for zy_city_match_fs_lose
-- ----------------------------
DROP TABLE IF EXISTS `zy_city_match_fs_lose`;
CREATE TABLE `zy_city_match_fs_lose`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `rank` int(10) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for zy_city_match_hx_lose
-- ----------------------------
DROP TABLE IF EXISTS `zy_city_match_hx_lose`;
CREATE TABLE `zy_city_match_hx_lose`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for zy_city_match_rank_fs
-- ----------------------------
DROP TABLE IF EXISTS `zy_city_match_rank_fs`;
CREATE TABLE `zy_city_match_rank_fs`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `award` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `rank` int(10) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for zy_city_match_rank_hx
-- ----------------------------
DROP TABLE IF EXISTS `zy_city_match_rank_hx`;
CREATE TABLE `zy_city_match_rank_hx`  (
  `player_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `award` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `rank` int(10) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛场次日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- View structure for player_first_login
-- ----------------------------
DROP VIEW IF EXISTS `player_first_login`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `player_first_login` AS select `a`.`id` AS `id`,`a`.`first_login_time` AS `login_time` from (`jygame`.`player_login_stat` `a` join (select `jygame`.`player_verify`.`login_id` AS `login_id`,`jygame`.`player_verify`.`channel_type` AS `channel_type`,`jygame`.`player_verify`.`password` AS `password`,`jygame`.`player_verify`.`id` AS `id`,`jygame`.`player_verify`.`refresh_token` AS `refresh_token`,`jygame`.`player_verify`.`extend_1` AS `extend_1`,`jygame`.`player_verify`.`extend_2` AS `extend_2` from `jygame`.`player_verify` where (`jygame`.`player_verify`.`channel_type` = 'wechat')) `b` on((`a`.`id` = `b`.`id`)));

-- ----------------------------
-- View structure for player_first_pay
-- ----------------------------
DROP VIEW IF EXISTS `player_first_pay`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `player_first_pay` AS select `a`.`order_id` AS `order_id`,`a`.`player_id` AS `player_id`,`a`.`order_status` AS `order_status`,`a`.`error_desc` AS `error_desc`,`a`.`money_type` AS `money_type`,`a`.`money` AS `money`,`a`.`channel_type` AS `channel_type`,`a`.`channel_account_id` AS `channel_account_id`,`a`.`source_type` AS `source_type`,`a`.`product_id` AS `product_id`,`a`.`product_count` AS `product_count`,`a`.`product_desc` AS `product_desc`,`a`.`is_test` AS `is_test`,`a`.`create_time` AS `create_time`,`a`.`channel_product_id` AS `channel_product_id`,`a`.`channel_order_id` AS `channel_order_id`,`a`.`itunes_trans_id` AS `itunes_trans_id`,`a`.`end_time` AS `end_time` from (`jygame`.`player_pay_order_all` `a` join (select `player_pay_order_all`.`player_id` AS `player_id`,min(`player_pay_order_all`.`create_time`) AS `create_time` from `jygame`.`player_pay_order_all` group by `player_pay_order_all`.`player_id`) `b` on(((`a`.`player_id` = `b`.`player_id`) and (`a`.`create_time` = `b`.`create_time`))));

-- ----------------------------
-- View structure for player_friendgame_record
-- ----------------------------
DROP VIEW IF EXISTS `player_friendgame_record`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `player_friendgame_record` AS select `a`.`id` AS `id`,`a`.`game_name` AS `game_name`,`a`.`time` AS `time`,`a`.`room_no` AS `room_no`,`a`.`player_id` AS `player_id` from (select `jygame`.`friendgame_history_record`.`id` AS `id`,`jygame`.`friendgame_history_record`.`game_name` AS `game_name`,`jygame`.`friendgame_history_record`.`time` AS `time`,`jygame`.`friendgame_history_record`.`room_no` AS `room_no`,`jygame`.`friendgame_history_record`.`p1_id` AS `player_id` from `jygame`.`friendgame_history_record` where (`jygame`.`friendgame_history_record`.`p1_id` is not null)) `a` union select `b`.`id` AS `id`,`b`.`game_name` AS `game_name`,`b`.`time` AS `time`,`b`.`room_no` AS `room_no`,`b`.`player_id` AS `player_id` from (select `jygame`.`friendgame_history_record`.`id` AS `id`,`jygame`.`friendgame_history_record`.`game_name` AS `game_name`,`jygame`.`friendgame_history_record`.`time` AS `time`,`jygame`.`friendgame_history_record`.`room_no` AS `room_no`,`jygame`.`friendgame_history_record`.`p2_id` AS `player_id` from `jygame`.`friendgame_history_record` where (`jygame`.`friendgame_history_record`.`p2_id` is not null)) `b` union select `c`.`id` AS `id`,`c`.`game_name` AS `game_name`,`c`.`time` AS `time`,`c`.`room_no` AS `room_no`,`c`.`player_id` AS `player_id` from (select `jygame`.`friendgame_history_record`.`id` AS `id`,`jygame`.`friendgame_history_record`.`game_name` AS `game_name`,`jygame`.`friendgame_history_record`.`time` AS `time`,`jygame`.`friendgame_history_record`.`room_no` AS `room_no`,`jygame`.`friendgame_history_record`.`p3_id` AS `player_id` from `jygame`.`friendgame_history_record` where (`jygame`.`friendgame_history_record`.`p3_id` is not null)) `c` union select `d`.`id` AS `id`,`d`.`game_name` AS `game_name`,`d`.`time` AS `time`,`d`.`room_no` AS `room_no`,`d`.`player_id` AS `player_id` from (select `jygame`.`friendgame_history_record`.`id` AS `id`,`jygame`.`friendgame_history_record`.`game_name` AS `game_name`,`jygame`.`friendgame_history_record`.`time` AS `time`,`jygame`.`friendgame_history_record`.`room_no` AS `room_no`,`jygame`.`friendgame_history_record`.`p4_id` AS `player_id` from `jygame`.`friendgame_history_record` where (`jygame`.`friendgame_history_record`.`p4_id` is not null)) `d`;

-- ----------------------------
-- View structure for player_pay_order_all
-- ----------------------------
DROP VIEW IF EXISTS `player_pay_order_all`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `player_pay_order_all` AS select `player_pay_order_log`.`order_id` AS `order_id`,`player_pay_order_log`.`player_id` AS `player_id`,`player_pay_order_log`.`order_status` AS `order_status`,`player_pay_order_log`.`error_desc` AS `error_desc`,`player_pay_order_log`.`money_type` AS `money_type`,`player_pay_order_log`.`money` AS `money`,`player_pay_order_log`.`channel_type` AS `channel_type`,`player_pay_order_log`.`channel_account_id` AS `channel_account_id`,`player_pay_order_log`.`source_type` AS `source_type`,`player_pay_order_log`.`product_id` AS `product_id`,`player_pay_order_log`.`product_count` AS `product_count`,`player_pay_order_log`.`product_desc` AS `product_desc`,`player_pay_order_log`.`is_test` AS `is_test`,`player_pay_order_log`.`create_time` AS `create_time`,`player_pay_order_log`.`channel_product_id` AS `channel_product_id`,`player_pay_order_log`.`channel_order_id` AS `channel_order_id`,`player_pay_order_log`.`itunes_trans_id` AS `itunes_trans_id`,`player_pay_order_log`.`end_time` AS `end_time` from `player_pay_order_log` union select `player_pay_order`.`order_id` AS `order_id`,`player_pay_order`.`player_id` AS `player_id`,`player_pay_order`.`order_status` AS `order_status`,`player_pay_order`.`error_desc` AS `error_desc`,`player_pay_order`.`money_type` AS `money_type`,`player_pay_order`.`money` AS `money`,`player_pay_order`.`channel_type` AS `channel_type`,`player_pay_order`.`channel_account_id` AS `channel_account_id`,`player_pay_order`.`source_type` AS `source_type`,`player_pay_order`.`product_id` AS `product_id`,`player_pay_order`.`product_count` AS `product_count`,`player_pay_order`.`product_desc` AS `product_desc`,`player_pay_order`.`is_test` AS `is_test`,`player_pay_order`.`create_time` AS `create_time`,`player_pay_order`.`channel_product_id` AS `channel_product_id`,`player_pay_order`.`channel_order_id` AS `channel_order_id`,`player_pay_order`.`itunes_trans_id` AS `itunes_trans_id`,`player_pay_order`.`end_time` AS `end_time` from `player_pay_order`;

-- ----------------------------
-- View structure for player_withdraw_all
-- ----------------------------
DROP VIEW IF EXISTS `player_withdraw_all`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `player_withdraw_all` AS select `player_withdraw`.`withdraw_id` AS `withdraw_id`,`player_withdraw`.`player_id` AS `player_id`,`player_withdraw`.`withdraw_status` AS `withdraw_status`,`player_withdraw`.`error_desc` AS `error_desc`,`player_withdraw`.`money` AS `money`,`player_withdraw`.`src_type` AS `src_type`,`player_withdraw`.`asset_type` AS `asset_type`,`player_withdraw`.`channel_type` AS `channel_type`,`player_withdraw`.`channel_withdraw_id` AS `channel_withdraw_id`,`player_withdraw`.`channel_receiver_id` AS `channel_receiver_id`,`player_withdraw`.`create_time` AS `create_time`,`player_withdraw`.`complete_time` AS `complete_time`,`player_withdraw`.`comment` AS `comment` from `player_withdraw` union all select `player_withdraw_log`.`withdraw_id` AS `withdraw_id`,`player_withdraw_log`.`player_id` AS `player_id`,`player_withdraw_log`.`withdraw_status` AS `withdraw_status`,`player_withdraw_log`.`error_desc` AS `error_desc`,`player_withdraw_log`.`money` AS `money`,`player_withdraw_log`.`src_type` AS `src_type`,`player_withdraw_log`.`asset_type` AS `asset_type`,`player_withdraw_log`.`channel_type` AS `channel_type`,`player_withdraw_log`.`channel_withdraw_id` AS `channel_withdraw_id`,`player_withdraw_log`.`channel_receiver_id` AS `channel_receiver_id`,`player_withdraw_log`.`create_time` AS `create_time`,`player_withdraw_log`.`complete_time` AS `complete_time`,`player_withdraw_log`.`comment` AS `comment` from `player_withdraw_log`;

-- ----------------------------
-- Procedure structure for add_sczd_palyer_contribute
-- ----------------------------
DROP PROCEDURE IF EXISTS `add_sczd_palyer_contribute`;
delimiter ;;
CREATE PROCEDURE `add_sczd_palyer_contribute`(IN `_player_id` varchar(100),
IN `_parent_id` varchar(100),
IN `parent_active` int,
IN `parent_cache_active` int,
IN `change_type` varchar(50),
IN `contribut_type` varchar(50),
IN `contribute_value` int)
  SQL SECURITY INVOKER
BEGIN
	if parent_active = 1 then
		update sczd_player_base_info set total_contribution_for_parent = total_contribution_for_parent + contribute_value 
		where player_id = _player_id;
	end if;
	
	if change_type = 'bbsc' then
	
		if parent_active = 1 then
			update sczd_activity_info set bbsc_contribution_for_parent = bbsc_contribution_for_parent + contribute_value 
			where player_id = _player_id;
		end if;
		
		if parent_cache_active=1 then
			update sczd_activity_info set bbsc_contribution_cache = bbsc_contribution_cache + contribute_value 
			where player_id = _parent_id;
		end if;
		
	ELSEIF change_type = 'tglb1' or change_type = 'tglb2' then
		if parent_active = 1 then
			update sczd_activity_info set tglb_contribution_for_parent = tglb_contribution_for_parent + contribute_value 
			where player_id = _player_id;
		end if;
		
		if parent_cache_active=1 then
			update sczd_activity_info set tglb_contribution_cache = tglb_contribution_cache + contribute_value 
			where player_id = _parent_id;
		end if;
	ELSEIF change_type = 'vip_lb' then
		if parent_active = 1 then
			update sczd_activity_info set vip_contribution_for_parent = vip_contribution_for_parent + contribute_value 
			where player_id = _player_id;
		end if;
		
	end if;
	
	if parent_active = 1 then
		insert into sczd_income_deatails_log(player_id,parent_id,treasure_type,treasure_value,is_active)
		values(_player_id,_parent_id,contribut_type,contribute_value,1);

		# 父亲的总获得值 增加
		update sczd_player_base_info set total_get_award = total_get_award + contribute_value 
				where player_id = _parent_id;
	end if;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for change_1_parent_day_achievement_log
-- ----------------------------
DROP PROCEDURE IF EXISTS `change_1_parent_day_achievement_log`;
delimiter ;;
CREATE PROCEDURE `change_1_parent_day_achievement_log`(IN `player_id` varchar(50),
		IN `parent_id` varchar(50),
		IN `month_start` datetime,
		IN `inc_sign` int)
  SQL SECURITY INVOKER
BEGIN

	-- 更新一个父亲的日志
	
	declare base_time_stamp  int default 1514736240; -- 基准时间 unix_timestamp('2018-1-1 0:4:0')
	DECLARE done INT DEFAULT FALSE;
	
	declare _no1 int;
	declare _time1 datetime;
	declare _day1 int;
	declare _achievements1 bigint;
	declare _tuikuan1 bigint;
	declare _all_achievements1 bigint;
	declare _all_tuikuan1 bigint;
	
	declare _no2 int;
	declare _time2 datetime;
	declare _day2 int;
	declare _achievements2 bigint;
	declare _tuikuan2 bigint;
	declare _all_achievements2 bigint;
	declare _all_tuikuan2 bigint;
	
	declare day_log_cur cursor for select 
			a.`no` no1,a.time time1,a.`day` day1,a.achievements achievements1,a.tuikuan tuikuan1,a.all_achievements all_achievements1,a.all_tuikuan all_tuikuan1,
			b.`no` no2,b.time time2,b.`day` day2,b.achievements achievements2,b.tuikuan tuikuan2,b.all_achievements all_achievements2,b.all_tuikuan all_tuikuan2
	
	from      (select  sczd_player_day_achievements_log.*,((unix_timestamp(time) - base_time_stamp) div 86400) `day` from sczd_player_day_achievements_log where id=player_id and time > month_start) a
	left join (select  sczd_player_day_achievements_log.*,((unix_timestamp(time) - base_time_stamp) div 86400) `day` from sczd_player_day_achievements_log where id=parent_id and time > month_start) b
				
	on a.`day` = b.`day` order by a.`day`;
				
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	start TRANSACTION;
	
	open day_log_cur;
	cur_loop : loop
		fetch day_log_cur into _no1,_time1,_day1,_achievements1,_tuikuan1,_all_achievements1,_all_tuikuan1,
													 _no2,_time2,_day2,_achievements2,_tuikuan2,_all_achievements2,_all_tuikuan2;
													 
		IF done THEN
			LEAVE cur_loop;
		END IF;           
		 
		 if _no2 is null then
				insert into sczd_player_day_achievements_log(id,time,achievements,tuikuan,all_achievements,all_tuikuan) values(parent_id,_time1,_achievements1 * inc_sign,_tuikuan1 * inc_sign,_all_achievements1 * inc_sign,_all_tuikuan1 * inc_sign);
		 else
				update sczd_player_day_achievements_log set achievements=achievements+_achievements1 * inc_sign,
																										tuikuan=tuikuan+_tuikuan1 * inc_sign,
																										all_achievements=all_achievements+_all_achievements1 * inc_sign,
																										all_tuikuan=all_tuikuan+_all_tuikuan1 * inc_sign
				where `no` = _no2;
		 end if;
	
	end loop cur_loop;
	
	close day_log_cur;
	
	COMMIT ;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for change_parent_day_achievement_log
-- ----------------------------
DROP PROCEDURE IF EXISTS `change_parent_day_achievement_log`;
delimiter ;;
CREATE PROCEDURE `change_parent_day_achievement_log`(IN `player_id` varchar(50),
IN `old_parent_id` varchar(50),
IN `new_parent_id` varchar(50))
  SQL SECURITY INVOKER
BEGIN

	declare month_start datetime;
	
	-- 本月开始： 1 号的 凌晨 4 点算起
	set month_start = date_add(date_add(curdate(),interval -day(curdate())+1 day),interval 14400 second); 
	

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for clear_his_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `clear_his_data`;
delimiter ;;
CREATE PROCEDURE `clear_his_data`(IN `last_date` date,IN `clear_count` int)
BEGIN
	
	delete from player_asset_log where date < last_date limit clear_count;

	delete from player_login_log where login_time < last_date limit clear_count;
	
	delete from player_task_log where time < last_date limit clear_count;
	
	delete from nor_ddz_nor_race_log where begin_time < last_date limit clear_count;
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for clear_his_data_batch
-- ----------------------------
DROP PROCEDURE IF EXISTS `clear_his_data_batch`;
delimiter ;;
CREATE PROCEDURE `clear_his_data_batch`(IN `clear_count` int,IN `batch_count` int)
BEGIN
	
	declare i int;
	
	set i=0;
	while i < batch_count do
		call clear_his_data('2019-11-25 0:0:0',clear_count);
		set i=i+1;
		
		set @xxx = sleep(10);
	end while;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for daily_clearup_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `daily_clearup_data`;
delimiter ;;
CREATE PROCEDURE `daily_clearup_data`()
  SQL SECURITY INVOKER
BEGIN


	-- 每天例行的数据清理

		declare last_day datetime;
		declare last_month datetime;
		declare last_week datetime;
		
		set last_day = DATE_ADD(now(),INTERVAL -1 DAY);
		set last_month = DATE_ADD(now(),INTERVAL -1 MONTH);
		set last_week = DATE_ADD(now(),INTERVAL -1 WEEK);
		
    start transaction;
	
    -- 登陆表：删除离线超过 7 天的（非活跃用户）
    delete from player_login where logout_time < last_week or (logout_time = null and login_time < last_week);
    
    -- 购物表：一个月前的数据移到日志表
    insert into player_shop_order_log(order_id,player_id,order_status,amount,shoping_desc,shoping_time,refund_time,goods_id,props_json,authflags_json,actual_amount) 
    select order_id,player_id,order_status,amount,shoping_desc,shoping_time,refund_time,goods_id,props_json,authflags_json,actual_amount from player_shop_order where shoping_time < last_month;
    delete from player_shop_order where shoping_time < last_month;
    
    -- 提现表：一天前且完成或 一周前且未完成 的数据移到日志表
    insert into player_withdraw_log(withdraw_id,player_id,withdraw_status,error_desc,money,src_type,asset_type,channel_type,channel_withdraw_id,channel_receiver_id,create_time,complete_time)
    select withdraw_id,player_id,withdraw_status,error_desc,money,src_type,asset_type,channel_type,channel_withdraw_id,channel_receiver_id,create_time,complete_time from player_withdraw where (withdraw_status='complete' and complete_time < last_day) or (withdraw_status<>'complete' and complete_time < last_week);
    delete from player_withdraw where (withdraw_status='complete' and complete_time < last_day) or (withdraw_status<>'complete' and complete_time < last_week);
    
    -- 充值详情表：一天前且完成 或 一周前且未完成 的数据移到日志表
    insert into player_pay_order_detail_log(order_id,asset_type,asset_count)
    select a.order_id,a.asset_type,a.asset_count from player_pay_order_detail a left join player_pay_order b on a.order_id = b.order_id
    where isnull(b.order_id) or (b.order_status='complete' and b.create_time < last_day) or (b.order_status<>'complete' and b.create_time < last_week);
    delete a from player_pay_order_detail a left join player_pay_order b on a.order_id = b.order_id
    where isnull(b.order_id) or (b.order_status='complete' and b.create_time < last_day) or (b.order_status<>'complete' and b.create_time < last_week);
    
    -- 充值表：一天前且完成 或 一周前且未完成 的数据移到日志表
    INSERT INTO `player_pay_order_log`
		(`order_id`,
		`player_id`,
		`order_status`,
		`error_desc`,
		`money_type`,
		`money`,
		`channel_type`,
		`channel_account_id`,
		`source_type`,
		`product_id`,
		`product_count`,
		`product_desc`,
		`is_test`,
		`create_time`,
		`channel_product_id`,
		`channel_order_id`,
		`itunes_trans_id`,
		`end_time`)
	SELECT `order_id`,
		`player_id`,
		`order_status`,
		`error_desc`,
		`money_type`,
		`money`,
		`channel_type`,
		`channel_account_id`,
		`source_type`,
		`product_id`,
		`product_count`,
		`product_desc`,
		`is_test`,
		`create_time`,
		`channel_product_id`,
		`channel_order_id`,
		`itunes_trans_id`,
		`end_time`
	FROM `player_pay_order`
	WHERE (order_status='complete' and create_time < last_day) or (order_status<>'complete' and create_time < last_week);
	
  delete from player_pay_order WHERE (order_status='complete' and create_time < last_day) or (order_status<>'complete' and create_time < last_week);
    
		
		
    commit;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for daily_clearup_statistics_tag_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `daily_clearup_statistics_tag_data`;
delimiter ;;
CREATE PROCEDURE `daily_clearup_statistics_tag_data`()
  SQL SECURITY INVOKER
BEGIN

    start transaction;
    
		# add by wss 迁移玩家的标签统计数据
		insert into statistics_player_tag_log ( player_id , tag_name , time ) 
		select player_id , tag_name , FROM_UNIXTIME(time) from statistics_player_tag; 
		delete from statistics_player_tag;
		
		
    commit;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for eachhour_clearup_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `eachhour_clearup_data`;
delimiter ;;
CREATE PROCEDURE `eachhour_clearup_data`()
  SQL SECURITY INVOKER
BEGIN

	-- 处理 每小时（整点）要统计 清理的 数据 
    
	call stat_club_total_consume();
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for exec_sql_begin
-- ----------------------------
DROP PROCEDURE IF EXISTS `exec_sql_begin`;
delimiter ;;
CREATE PROCEDURE `exec_sql_begin`()
  SQL SECURITY INVOKER
BEGIN

	set @_esi_stat_index = 0;  # !!! 千万不要改 此变量名字！！！
	set @_esi_stat_ts = unix_timestamp(current_timestamp(6));
	
	set @_esi_cur_ts = @_esi_stat_ts;
	delete from exec_sql_info where proc_id = connection_id();

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for exec_sql_deal
-- ----------------------------
DROP PROCEDURE IF EXISTS `exec_sql_deal`;
delimiter ;;
CREATE PROCEDURE `exec_sql_deal`()
  SQL SECURITY INVOKER
BEGIN

	declare _esi_cur_ts0 double;

	set @_esi_stat_index = @_esi_stat_index + 1;  # !!! 千万不要改 此变量名字！！！
	set _esi_cur_ts0 = @_esi_cur_ts;
	set @_esi_cur_ts = unix_timestamp(current_timestamp(6));

	insert into exec_sql_info(proc_id,statement_index,dur) values (connection_id(),@_esi_stat_index,@_esi_cur_ts-_esi_cur_ts0);
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for exec_sql_end
-- ----------------------------
DROP PROCEDURE IF EXISTS `exec_sql_end`;
delimiter ;;
CREATE PROCEDURE `exec_sql_end`()
  SQL SECURITY INVOKER
BEGIN

	# 调试环境 用于统计； 正式环境 注释掉以下代码

	declare _esi_cur_ts0 double;
	set _esi_cur_ts0=unix_timestamp(current_timestamp(6));
	
	insert into exec_sql_info_batch(proc_id,batch_dur) values(connection_id(),_esi_cur_ts0-@_esi_stat_ts);
	insert into exec_sql_info_log(batch_id,statement_index,dur) select last_insert_id(),statement_index,dur from exec_sql_info where proc_id = connection_id();
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for generate_ancestor
-- ----------------------------
DROP PROCEDURE IF EXISTS `generate_ancestor`;
delimiter ;;
CREATE PROCEDURE `generate_ancestor`()
  SQL SECURITY INVOKER
BEGIN
	
		-- 所有的上级表（最多 21 级）
		truncate player_ancestor;
		insert into player_ancestor(player_id,parent_1) select offspring_id,player_id from player_offspring a where offspring_num=1 on duplicate key update parent_1 = a.player_id;
		insert into player_ancestor(player_id,parent_2) select offspring_id,player_id from player_offspring a where offspring_num=2 on duplicate key update parent_2 = a.player_id;
		insert into player_ancestor(player_id,parent_3) select offspring_id,player_id from player_offspring a where offspring_num=3 on duplicate key update parent_3 = a.player_id;
		insert into player_ancestor(player_id,parent_4) select offspring_id,player_id from player_offspring a where offspring_num=4 on duplicate key update parent_4 = a.player_id;
		insert into player_ancestor(player_id,parent_5) select offspring_id,player_id from player_offspring a where offspring_num=5 on duplicate key update parent_5 = a.player_id;
		insert into player_ancestor(player_id,parent_6) select offspring_id,player_id from player_offspring a where offspring_num=6 on duplicate key update parent_6 = a.player_id;
		insert into player_ancestor(player_id,parent_7) select offspring_id,player_id from player_offspring a where offspring_num=7 on duplicate key update parent_7 = a.player_id;
		insert into player_ancestor(player_id,parent_8) select offspring_id,player_id from player_offspring a where offspring_num=8 on duplicate key update parent_8 = a.player_id;
		insert into player_ancestor(player_id,parent_9) select offspring_id,player_id from player_offspring a where offspring_num=9 on duplicate key update parent_9 = a.player_id;
		insert into player_ancestor(player_id,parent_10) select offspring_id,player_id from player_offspring a where offspring_num=10 on duplicate key update parent_10 = a.player_id;
		insert into player_ancestor(player_id,parent_11) select offspring_id,player_id from player_offspring a where offspring_num=11 on duplicate key update parent_11 = a.player_id;
		insert into player_ancestor(player_id,parent_12) select offspring_id,player_id from player_offspring a where offspring_num=12 on duplicate key update parent_12 = a.player_id;
		insert into player_ancestor(player_id,parent_13) select offspring_id,player_id from player_offspring a where offspring_num=13 on duplicate key update parent_13 = a.player_id;
		insert into player_ancestor(player_id,parent_14) select offspring_id,player_id from player_offspring a where offspring_num=14 on duplicate key update parent_14 = a.player_id;
		insert into player_ancestor(player_id,parent_15) select offspring_id,player_id from player_offspring a where offspring_num=15 on duplicate key update parent_15 = a.player_id;
		insert into player_ancestor(player_id,parent_16) select offspring_id,player_id from player_offspring a where offspring_num=16 on duplicate key update parent_16 = a.player_id;
		insert into player_ancestor(player_id,parent_17) select offspring_id,player_id from player_offspring a where offspring_num=17 on duplicate key update parent_17 = a.player_id;
		insert into player_ancestor(player_id,parent_18) select offspring_id,player_id from player_offspring a where offspring_num=18 on duplicate key update parent_18 = a.player_id;
		insert into player_ancestor(player_id,parent_19) select offspring_id,player_id from player_offspring a where offspring_num=19 on duplicate key update parent_19 = a.player_id;
		insert into player_ancestor(player_id,parent_20) select offspring_id,player_id from player_offspring a where offspring_num=20 on duplicate key update parent_20 = a.player_id;
		insert into player_ancestor(player_id,parent_21) select offspring_id,player_id from player_offspring a where offspring_num=21 on duplicate key update parent_21 = a.player_id;

	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for generate_offspring
-- ----------------------------
DROP PROCEDURE IF EXISTS `generate_offspring`;
delimiter ;;
CREATE PROCEDURE `generate_offspring`()
  SQL SECURITY INVOKER
BEGIN

		declare last_level int;

		truncate player_offspring_prepare;

		-- 直接孩子
		insert into player_offspring_prepare(player_id,offspring_id,offsprint_parent_id,offspring_num) 
		select parent_id,id,parent_id,1 from sczd_relation_data 
		where parent_id is not null;

		set last_level = 1;

		-- 重复取得其它级
		repeat

			insert into player_offspring_prepare(player_id,offspring_id,offsprint_parent_id,offspring_num) 
			select a.player_id,b.id,a.offspring_id,last_level+1 from player_offspring_prepare a
			inner join sczd_relation_data b on a.offspring_id = b.parent_id
			where b.parent_id is not null and a.offspring_num = last_level;

			set last_level = last_level + 1;
		until ROW_COUNT() = 0 end repeat;

		-- 吧自己加入
		insert into player_offspring_prepare(player_id,offspring_id,offsprint_parent_id,offspring_num) 
		select id,id,parent_id,0 from sczd_relation_data;

	START TRANSACTION;
	
		truncate player_offspring;
		insert into player_offspring(player_id,offspring_id,offsprint_parent_id,offspring_num)
		select player_id,offspring_id,offsprint_parent_id,offspring_num from player_offspring_prepare;
		
		-- 所属的高级合伙人
		truncate player_gjhhr;
		insert into player_gjhhr(player_id,gjhhr,offspring_num)
		select a.offspring_id,b.player_id,a.offspring_num from (
			select a.offspring_id,min(a.offspring_num) offspring_num from player_offspring_prepare a 
			inner join sczd_relation_data b on a.player_id = b.id 
			where b.is_gjhhr = 1 and a.offspring_num > 0
			group by a.offspring_id
		) a inner join player_offspring_prepare b on a.offspring_id = b.offspring_id and a.offspring_num = b.offspring_num;
		
	COMMIT;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for gen_player_asset_refund
-- ----------------------------
DROP PROCEDURE IF EXISTS `gen_player_asset_refund`;
delimiter ;;
CREATE PROCEDURE `gen_player_asset_refund`()
  SQL SECURITY INVOKER
BEGIN

	-- 处理玩家 asset 财富的退款记录
    
		declare max_asset_refund_seq bigint;
		declare done int default 0;
        
        declare refund_max_time int default 900; -- 退款的最长时间，单位 秒
		
		declare tmp_log_id int;
		declare tmp_player_id varchar(50);
		declare tmp_date_sec int; -- 时间，秒
		declare tmp_asset_type varchar(50);
		declare tmp_change_value bigint;
		declare tmp_refund_change_type varchar(50);
		declare tmp_sync_seq bigint;
		declare tmp_change_type varchar(50);
		
		declare ins_log_id_consume int;
        
        declare last_refund_seq bigint;
        declare last_safe_seq bigint;
        
				
		DECLARE cur_asset CURSOR FOR select a.log_id,a.id,unix_timestamp(a.date),a.asset_type,a.change_value,a.change_type,a.sync_seq,b.change_type
							from player_asset_log a 
							inner join player_change_type_refund b on a.change_type=b.change_type_refund 
							where a.sync_seq > if(max_asset_refund_seq is null,0,max_asset_refund_seq)
							order by a.sync_seq limit 100;
		declare continue handler for not FOUND set done=1;
    
		-- 消费数据和退款数据配对：将退款和之前 n 分钟以内的 消费配对
		select max(seq_refund) into max_asset_refund_seq from player_asset_refund;
    
		open cur_asset;
		FETCH cur_asset INTO tmp_log_id,tmp_player_id,tmp_date_sec,tmp_asset_type,tmp_change_value,tmp_refund_change_type,tmp_sync_seq,tmp_change_type;
		while done <> 1 do
		
				-- 找对应的消费项目：往回找第一个匹配的
				select a.log_id into ins_log_id_consume from player_asset_log a 
				left join player_asset_refund b on a.log_id = b.log_id 
				where a.change_type = tmp_change_type and a.id=tmp_player_id and a.change_value = -tmp_change_value and a.sync_seq < tmp_sync_seq and b.log_id is null and (tmp_date_sec - unix_timestamp(a.date)) <= refund_max_time 
				order by a.date desc limit 1;
				
				if ins_log_id_consume is null then
						set done = 1;		-- 有异常：找不到对应消费项，不再继续
						insert into system_error(error_name,error_sn,error_info) 
						values('asset_log_refund',tmp_log_id,'退款未发现消费数据！') 
						on duplicate key update error_info = '退款未发现消费数据！';
				else
						insert into player_asset_refund(log_id,log_id_refund,seq_refund) values (ins_log_id_consume,tmp_log_id,tmp_sync_seq);
                        set last_refund_seq = tmp_sync_seq;
				end if;
				
				FETCH cur_asset INTO tmp_log_id,tmp_player_id,tmp_date_sec,tmp_asset_type,tmp_change_value,tmp_refund_change_type,tmp_sync_seq,tmp_change_type;		
		end while;
		close cur_asset;
        
        if last_refund_seq is null then
        
			-- 没有退款，则赋给限制时间前最大的
			select max(sync_seq) into last_safe_seq from player_asset_log where (unix_timestamp(now()) - unix_timestamp(`date`)) >= refund_max_time; 
		else
        
			-- 记录安全数据的 seq ：第一个未处理 退款前 n 分钟
			select unix_timestamp(a.date) into tmp_date_sec from player_asset_log a 
			inner join player_change_type_refund b on a.change_type=b.change_type_refund 
			where a.sync_seq > if(last_refund_seq is null,0,last_refund_seq) order by a.sync_seq limit 1; 
			
			if tmp_date_sec is null then
			
				-- 没有退款，则赋给限制时间前最大的
			
				select max(sync_seq) into last_safe_seq from player_asset_log where (unix_timestamp(now()) - unix_timestamp(`date`)) >= refund_max_time; 
			else
				select sync_seq into last_safe_seq from player_asset_log
				where tmp_date_sec - unix_timestamp(date) >= refund_max_time order by sync_seq desc limit 1; 
			end if;
            
		end if;
        
        if last_safe_seq is not null then
			insert into system_variant(`name`,`value`) values('last_asset_safe_seq',if(last_safe_seq is null,0,last_safe_seq)) 
			on duplicate key update `value` = if(last_safe_seq is null,0,last_safe_seq);
		end if;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for gen_player_prop_refund
-- ----------------------------
DROP PROCEDURE IF EXISTS `gen_player_prop_refund`;
delimiter ;;
CREATE PROCEDURE `gen_player_prop_refund`()
  SQL SECURITY INVOKER
BEGIN

	-- 处理玩家 prop 财富的退款记录
    
		declare max_prop_refund_seq bigint;
		declare done int default 0;
		
		declare tmp_log_id int;
		declare tmp_player_id varchar(50);
		declare tmp_date_sec int; -- 时间，秒
		declare tmp_prop_type varchar(50);
		declare tmp_change_value bigint;
		declare tmp_refund_change_type varchar(50);
		declare tmp_sync_seq bigint;
		declare tmp_change_type varchar(50);
		
		declare ins_log_id_consume int;
				
		DECLARE cur_prop CURSOR FOR select a.log_id,a.id,unix_timestamp(a.date),a.prop_type,a.change_value,a.change_type,a.shop_gold_sync_seq,b.change_type
							from player_prop_log a 
							inner join player_change_type_refund b on a.change_type=b.change_type_refund 
							where a.shop_gold_sync_seq > if(max_prop_refund_seq is null,0,max_prop_refund_seq)
							order by a.shop_gold_sync_seq limit 100;
		declare continue handler for not FOUND set done=1;
    
		-- 消费数据和退款数据配对：将退款和之前 n 分钟以内的 消费配对
		select max(seq_refund) into max_prop_refund_seq from player_prop_refund;
    
		open cur_prop;
		FETCH cur_prop INTO tmp_log_id,tmp_player_id,tmp_date_sec,tmp_prop_type,tmp_change_value,tmp_refund_change_type,tmp_sync_seq,tmp_change_type;
		while done <> 1 do
		
				-- 找对应的消费项目：往回找第一个匹配的
				select a.log_id into ins_log_id_consume from player_prop_log a 
				left join player_prop_refund b on a.log_id = b.log_id 
				where a.change_type = tmp_change_type and a.id=tmp_player_id and a.change_value = -tmp_change_value and a.shop_gold_sync_seq < tmp_sync_seq and b.log_id is null and tmp_date_sec - unix_timestamp(a.date) < 900 
				order by a.date desc limit 1;
				
				if ins_log_id_consume is null then
						set done = 1;		-- 有异常：找不到对应消费项，不再继续
						insert into system_error(error_name,error_sn,error_info) 
						values('prop_log_refund',tmp_log_id,'退款未发现消费数据！') 
						on duplicate key update error_info = '退款未发现消费数据！';
				else
						insert into player_prop_refund(log_id,log_id_refund,seq_refund) values (ins_log_id_consume,tmp_log_id,tmp_sync_seq);
				end if;
				
				FETCH cur_prop INTO tmp_log_id,tmp_player_id,tmp_date_sec,tmp_prop_type,tmp_change_value,tmp_refund_change_type,tmp_sync_seq,tmp_change_type;		
		end while;
		close cur_prop;	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for get_last_sczd_profit
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_last_sczd_profit`;
delimiter ;;
CREATE PROCEDURE `get_last_sczd_profit`(IN _player_id VARCHAR(50))
  SQL SECURITY INVOKER
BEGIN
  select ifnull(sum(treasure_value),0) last_profit from sczd_income_deatails_log A LEFT JOIN player_login B on A.parent_id = B.id where A.parent_id = _player_id and A.treasure_type <> 105 and A.treasure_type <> 110 and A.time > B.logout_time;

	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for get_sczd_all_son_main_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_sczd_all_son_main_info`;
delimiter ;;
CREATE PROCEDURE `get_sczd_all_son_main_info`(IN _player_id VARCHAR(50))
  SQL SECURITY INVOKER
BEGIN
  #Routine body goes here...
	select 
		a.id,
		a.`name`,
		a.logined,
		ifnull(b.total_contribution_for_parent,0) my_all_gx,
		unix_timestamp(c.register_time) register_time,
		unix_timestamp(d.last_login_time) last_login_time ,
		ifnull( (select UNIX_TIMESTAMP(time) from sczd_income_deatails_log where player_id = a.id and parent_id = _player_id order by time desc limit 1) ,0) last_gx_time ,
		IFNULL(E.now_big_step,1) now_big_step,
		IFNULL(E.now_little_step,1) now_little_step,
		IFNULL(F.is_buy_vip_lb,0) is_buy_vip_lb,
		IFNULL(G.is_buy_goldpig,0) is_buy_goldpig1_old,
		IFNULL(G.is_buy_goldpig1,0) is_buy_goldpig1,
		IFNULL(G.is_buy_goldpig2,0) is_buy_goldpig2,
		IFNULL( (select join_qys_num from statistics_player_game_info where player_id = a.id) , 0) as join_qys_num ,
		ifnull( (select count(*) from sczd_income_deatails_log where player_id = a.id and parent_id = _player_id and treasure_type = 150 limit 1) , 0) as bisai_contribution_num ,
		ifnull( (select count(*) from sczd_income_deatails_log where player_id = a.id and parent_id = _player_id and treasure_type = 101 limit 1) , 0) as goldpig_lb1_contribution_num ,
		ifnull( (select count(*) from sczd_income_deatails_log where player_id = a.id and parent_id = _player_id and treasure_type = 102 limit 1) , 0) as goldpig_lb2_contribution_num ,
		ifnull( (select count(*) from sczd_income_deatails_log where player_id = a.id and parent_id = _player_id and treasure_type = 103 limit 1) , 0) as vip_lb_contribution_num ,
		ifnull( (select is_buy from sczd_all_return_lb_data where player_id = a.id and all_return_bag_type = 'all_return_lb_1' ) , 0 ) as is_buy_all_return_bag_1 ,
		ifnull( (select is_buy from sczd_all_return_lb_data where player_id = a.id and all_return_bag_type = 'all_return_lb_2' ) , 0 ) as is_buy_all_return_bag_2 ,
		ifnull( (select is_buy from sczd_all_return_lb_data where player_id = a.id and all_return_bag_type = 'all_return_lb_3' ) , 0 ) as is_buy_all_return_bag_3 
		from player_info a 
		left join sczd_player_base_info b on a.id = b.player_id
		left join player_register c on a.id = c.id
		left join player_login_stat d on a.id = d.id
		left join player_stepstep_money E on a.id = E.player_id
		left join sczd_vip_lb_info F on a.id = F.player_id
		left join player_goldpig_info G on a.id = G.player_id
		where a.id in (select id from sczd_relation_data where parent_id = _player_id);
	
		
	
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for get_sczd_base_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_sczd_base_info`;
delimiter ;;
CREATE PROCEDURE `get_sczd_base_info`(IN _player_id varchar(50) 
	, out _total_get_award int 
	, out _is_activate_bbsc_profit TINYINT 
	, out _is_activate_xj_profit TINYINT 
	, out _is_activate_xj_profit2 TINYINT 
	, out _is_activate_xj_profit3 TINYINT 
	, out _is_activate_tglb_profit TINYINT 
	, out _is_activate_tglb_cache TINYINT 
	, out _is_activate_tgy_tx_profit TINYINT
	, out _is_activate_bisai_profit TINYINT
	, out _now_big_step TINYINT
	, out _now_little_step TINYINT
	, out _is_buy_vip_lb TINYINT
	, out _is_buy_goldpig1_old TINYINT
	, out _is_buy_goldpig1 TINYINT
	, out _is_buy_goldpig2 TINYINT
	, out _join_qys_num INT
	, out _gjhhr_status VARCHAR(255) 
	, out _my_all_gx int
	, out _all_son_count int
	, out _goldpig_profit_cache int)
  SQL SECURITY INVOKER
BEGIN
	#Routine body goes here...
	declare p_goldpig_pay_player VARCHAR(50) DEFAULT '';
	declare p_is_activate_bbsc_profit TINYINT DEFAULT 99;
	declare p_sczd_activity_data_num TINYINT DEFAULT 0;
	declare p_bbsc_data_num TINYINT DEFAULT 0;
	declare p_all_son_num INT DEFAULT 0;
	declare p_gjhhr_status VARCHAR(255) DEFAULT '';

	select IFNULL(is_activate_bbsc_profit,1) , IFNULL(is_activate_xj_profit,1) , IFNULL(is_activate_xj_profit2,0) , IFNULL(is_activate_xj_profit3,0) , IFNULL(is_activate_tglb_profit,0) , IFNULL(is_activate_tglb_cache,0), IFNULL(is_activate_tgy_tx_profit,1), IFNULL(is_activate_bisai_profit,0),ifnull(total_get_award,0),ifnull(total_contribution_for_parent,0) , ifnull(all_son_count,0) into p_is_activate_bbsc_profit , _is_activate_xj_profit , _is_activate_xj_profit2 , _is_activate_xj_profit3 , _is_activate_tglb_profit , _is_activate_tglb_cache , _is_activate_tgy_tx_profit , _is_activate_bisai_profit ,_total_get_award, _my_all_gx,_all_son_count from sczd_player_base_info where player_id= _player_id;
	
	####
	select COUNT(*) into p_sczd_activity_data_num from sczd_activity_info WHERE player_id = _player_id;
	
	if p_sczd_activity_data_num = 0 then
		insert into sczd_activity_info(player_id,tglb_contribution_for_parent,bbsc_contribution_for_parent,vip_contribution_for_parent,tglb_contribution_cache,bbsc_contribution_cache,qys_contribution_cache_for_parent) values(_player_id,0,0,0,0,0,0);
		set _goldpig_profit_cache = 0;
	else
		select tglb_contribution_cache into _goldpig_profit_cache from sczd_activity_info WHERE player_id = _player_id;
	end if;
	
	#### 步步生财数据
	select COUNT(*) into p_bbsc_data_num from player_stepstep_money WHERE player_id = _player_id;
	if p_bbsc_data_num = 0 then
		insert into player_stepstep_money(player_id,now_big_step,now_little_step,last_op_time,can_do_big_step) values(_player_id,1,1, UNIX_TIMESTAMP(NOW()) ,1);
	end if;
	
	# 获取当前的bbsc大步骤，小步骤
	select IFNULL(now_big_step,1) , IFNULL(now_little_step,1) into _now_big_step,_now_little_step from player_stepstep_money where player_id = _player_id;
	
	# 获取vip礼包是否购买
	select IFNULL(is_buy_vip_lb,0) into _is_buy_vip_lb from sczd_vip_lb_info where player_id = _player_id;
	
	# 获取金猪礼包购买情况
	select IFNULL(is_buy_goldpig,0),IFNULL(is_buy_goldpig1,0),IFNULL(is_buy_goldpig2,0) INTO _is_buy_goldpig1_old,_is_buy_goldpig1,_is_buy_goldpig2 FROM player_goldpig_info where player_id = _player_id;
	
	# 获取参加过千元赛的次数
	#select count(*) into _join_qys_num from naming_match_rank where player_id = _player_id;
	set _join_qys_num = IFNULL( (select join_qys_num from statistics_player_game_info where player_id = _player_id),0);
	
	# 没有数据，插入一条
	if p_is_activate_bbsc_profit = 99 then
		select count(*) into p_all_son_num from sczd_relation_data where parent_id = _player_id;
	
		insert into sczd_player_base_info(player_id,total_get_award,is_activate_bbsc_profit, is_activate_xj_profit , is_activate_xj_profit2 , is_activate_xj_profit3 , is_activate_tglb_profit, is_activate_tglb_cache , is_activate_tgy_tx_profit, is_activate_bisai_profit,total_contribution_for_parent,all_son_count) values(_player_id,0,1,1,0,0,1,0,1,0,0,p_all_son_num);
		set _total_get_award = 0;
		set p_is_activate_bbsc_profit = 1;
		set _is_activate_xj_profit = 1;
		set _is_activate_xj_profit2 = 0;
		set _is_activate_xj_profit3 = 0;
		set _is_activate_tglb_profit = 1;
		set _is_activate_tglb_cache = 0;
		set _is_activate_tgy_tx_profit = 1;
		set _is_activate_bisai_profit = 0;
		set _my_all_gx = 0;
		set _all_son_count = p_all_son_num;
	end if;
	set _is_activate_bbsc_profit = p_is_activate_bbsc_profit;
	
	# 查是否是高级合伙人
	select `status` into p_gjhhr_status from sczd_gjhhr_info where id = _player_id;
	if p_gjhhr_status = '' then
		set p_gjhhr_status = 'freeze';
	end if;
	set _gjhhr_status = p_gjhhr_status;


	#select player_id into p_goldpig_pay_player from player_goldpig_info where player_id = _player_id and is_buy_goldpig = 1;
	
	#if p_goldpig_pay_player = '' or not p_goldpig_pay_player then
	#	set _is_active_tglb1_profit = 0 ;
	#else
	#	set _is_active_tglb1_profit = 1 ;
	#end if;
	
	
	#select ifnull(b.total_contribution_for_parent,0) into _my_all_gx from sczd_player_base_info b where b.player_id = _player_id;
	

END
;;
delimiter ;

-- ----------------------------
-- Function structure for get_variant_int
-- ----------------------------
DROP FUNCTION IF EXISTS `get_variant_int`;
delimiter ;;
CREATE FUNCTION `get_variant_int`(var_name varchar(100))
 RETURNS int(11)
  READS SQL DATA 
  SQL SECURITY INVOKER
BEGIN

	declare _value varchar(500);

	select value into _value from system_variant where name = var_name;
    
	RETURN CONVERT(_value,SIGNED);
END
;;
delimiter ;

-- ----------------------------
-- Function structure for get_variant_uint
-- ----------------------------
DROP FUNCTION IF EXISTS `get_variant_uint`;
delimiter ;;
CREATE FUNCTION `get_variant_uint`(var_name varchar(100))
 RETURNS int(10) unsigned
  READS SQL DATA 
  SQL SECURITY INVOKER
BEGIN
	declare _value varchar(500);

	select value into _value from system_variant where name = var_name;
    
	RETURN CONVERT(_value,UNSIGNED);
    
RETURN 1;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for get_variant_varchar
-- ----------------------------
DROP FUNCTION IF EXISTS `get_variant_varchar`;
delimiter ;;
CREATE FUNCTION `get_variant_varchar`(var_name varchar(100))
 RETURNS varchar(500) CHARSET utf8
  READS SQL DATA 
  SQL SECURITY INVOKER
BEGIN

	declare _value varchar(500);

	select value into _value from system_variant where name = var_name;
    
	RETURN _value;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for init_club_info_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `init_club_info_data`;
delimiter ;;
CREATE PROCEDURE `init_club_info_data`()
  SQL SECURITY INVOKER
BEGIN
declare _index int;

SET @_player_id = '1010870';
SET @_parent_id = '1021748';
SET @_parent_ids = '1021748';
SET _index = 0;
repeat
	SET @_player_id = @_player_id + 1;
	

	INSERT INTO club_info(id,parent_id,parent_ids,is_tgy,is_agent) VALUES (@_player_id,@_parent_id,@_parent_ids,1,1);
	SET _index = _index + 1;
until _index > 100
end repeat;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for init_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `init_data`;
delimiter ;;
CREATE PROCEDURE `init_data`()
  SQL SECURITY INVOKER
BEGIN
declare _id int;
declare _index int;


SET @_player_id = 1010870;
SET @_payback_palyer_id = 1021830;
SET @_payback_value = 1000;
SET @_buy_vip_day = 10;
SET @_buy_time = 1507932000;
SET _id = 0;
SET _index = 0;
repeat
	SET _id = _id + 1;

	SET  @_buy_time =  @_buy_time + 86400;

	INSERT INTO player_vip_buy_record(id,player_id,payback_player_id,payback_value,buy_vip_day,buy_time,buy_time_year,buy_time_month,buy_time_day) 
	VALUES (_id,@_player_id, @_payback_palyer_id,@_payback_value ,@_buy_vip_day, @_buy_time , DATE_FORMAT(FROM_UNIXTIME(@_buy_time),'%Y') , DATE_FORMAT(FROM_UNIXTIME(@_buy_time),'%m') , DATE_FORMAT(FROM_UNIXTIME(@_buy_time),'%d') );
	SET _index = _index + 1;
until _index > 200
end repeat;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for init_vip_buy_record
-- ----------------------------
DROP PROCEDURE IF EXISTS `init_vip_buy_record`;
delimiter ;;
CREATE PROCEDURE `init_vip_buy_record`()
  SQL SECURITY INVOKER
BEGIN
declare _id int;
declare _index int;


SET @_player_id = 1010870;
SET @_payback_palyer_id = 1022047;
SET @_payback_value = 1000;
SET @_buy_vip_day = 10;
SET @_buy_time = 1507932000;
SET _id = 203;
SET _index = 0;
repeat
	SET _id = _id + 1;

	SET  @_buy_time =  @_buy_time + 86400;

	INSERT INTO player_vip_buy_record(id,player_id,payback_player_id,payback_value,buy_vip_day,buy_time,buy_time_year,buy_time_month,buy_time_day) 
	VALUES (_id,@_player_id, @_payback_palyer_id,@_payback_value ,@_buy_vip_day, @_buy_time , DATE_FORMAT(FROM_UNIXTIME(@_buy_time),'%Y') , DATE_FORMAT(FROM_UNIXTIME(@_buy_time),'%m') , DATE_FORMAT(FROM_UNIXTIME(@_buy_time),'%d') );
	SET _index = _index + 1;
until _index > 1
end repeat;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for init_vip_extract_record
-- ----------------------------
DROP PROCEDURE IF EXISTS `init_vip_extract_record`;
delimiter ;;
CREATE PROCEDURE `init_vip_extract_record`()
  SQL SECURITY INVOKER
BEGIN
declare _index int;


SET @_player_id = 1022047;
SET @_extract_value = 10;
SET @_extract_time = 1507932000;
SET _index = 0;
repeat

	SET  @_extract_time =  @_extract_time + 86400;

	INSERT INTO player_vip_generalize_extract_record(player_id,extract_value,extract_time) 
	VALUES (@_player_id, @_extract_value,@_extract_time );
	SET _index = _index + 1;
until _index > 1
end repeat;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for minute5_clear_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `minute5_clear_data`;
delimiter ;;
CREATE PROCEDURE `minute5_clear_data`()
  SQL SECURITY INVOKER
BEGIN

	-- 每5分钟处理的数据清理（程序中还没 加调用）
    
		
		
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for minute_clear_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `minute_clear_data`;
delimiter ;;
CREATE PROCEDURE `minute_clear_data`()
  SQL SECURITY INVOKER
BEGIN

	-- 每分钟处理的数据清理
	
	-- 分钟计数器 清理
	update system_variant set `value` = `value` + 1 where `name` = 'minute_clear_count' ;
  set @minute_clear_count = get_variant_int('minute_clear_count');
	
	-- if @minute_clear_count mod 10 = 0 then
	-- 	call generate_offspring();
	-- end if;
	
	-- if @minute_clear_count mod 30 = 0 then
	-- 	call generate_ancestor();
	-- end if;
  
    -- 财富 退款
	-- call gen_player_asset_refund();
  -- call gen_player_prop_refund();
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for query_all_average_rate
-- ----------------------------
DROP PROCEDURE IF EXISTS `query_all_average_rate`;
delimiter ;;
CREATE PROCEDURE `query_all_average_rate`()
BEGIN

SET @_start_time = "2019-04-20 00:00:00";
SET @_end_time = "2019-05-30 00:00:00";

SET @_all_ddz_win_rate = 0;
SET @_all_ddz_lose_rate = 0;

SET @_all_ddz_win_p_num = 0;
SET @_all_ddz_lose_p_num = 0;

SET @_all_mj_win_rate = 0;
SET @_all_mj_lose_rate = 0;

SET @_all_mj_win_p_num = 0;
SET @_all_mj_lose_p_num = 0;


#斗地主赢
SELECT 
		frl.game_id game_id,@_all_ddz_win_p_num:=COUNT(distinct frpl.player_id) wp, @_all_ddz_win_rate:=SUM(ndnrpl.rate) rt
FROM 
		freestyle_race_log AS frl JOIN freestyle_race_player_log AS frpl ON frpl.match_id=frl.id
		JOIN nor_ddz_nor_race_log AS ndnrl ON frl.races = ndnrl.id
		JOIN nor_ddz_nor_race_player_log AS ndnrpl ON ndnrpl.race_id=ndnrl.id
WHERE 
		frpl.score > 0 AND frl.begin_time > @_start_time AND frl.end_time < @_end_time
		AND frl.game_type LIKE "nor_ddz%"	AND ndnrpl.player_id = frpl.player_id
GROUP BY
	frl.game_id
;

#斗地主输
SELECT 
		frl.game_id game_id,@_all_ddz_lose_p_num:=COUNT(distinct frpl.player_id) lp, @_all_ddz_lose_rate:=SUM(ndnrpl.rate) rt
FROM 
		freestyle_race_log AS frl JOIN freestyle_race_player_log AS frpl ON frpl.match_id=frl.id
		JOIN nor_ddz_nor_race_log AS ndnrl ON frl.races = ndnrl.id
		JOIN nor_ddz_nor_race_player_log AS ndnrpl ON ndnrpl.race_id=ndnrl.id
WHERE 
		frpl.score < 0 AND frl.begin_time > @_start_time AND frl.end_time < @_end_time
		AND frl.game_type LIKE "nor_ddz%"	AND ndnrpl.player_id = frpl.player_id
GROUP BY
	frl.game_id
;


#麻将赢
SELECT 
		frl.game_id game_id,@_all_mj_win_p_num:=COUNT(distinct frpl.player_id) wp, @_all_mj_win_rate:=SUM(ndnrpl.multi) rt
FROM 
		freestyle_race_log AS frl JOIN freestyle_race_player_log AS frpl ON frpl.match_id=frl.id
		JOIN nor_mj_xzdd_race_log AS ndnrl ON frl.races = ndnrl.id
		JOIN nor_mj_xzdd_race_player_log AS ndnrpl ON ndnrpl.race_id=ndnrl.id
WHERE 
		frpl.score > 0 AND frl.begin_time > @_start_time AND frl.end_time < @_end_time
		AND frl.game_type LIKE "nor_mj%"	AND ndnrpl.player_id = frpl.player_id
GROUP BY
	frl.game_id
;


#麻将输
SELECT 
		frl.game_id game_id,@_all_mj_lose_p_num:=COUNT(distinct frpl.player_id) wp, @_all_mj_lose_rate:=SUM(ndnrpl.multi) rt
FROM 
		freestyle_race_log AS frl JOIN freestyle_race_player_log AS frpl ON frpl.match_id=frl.id
		JOIN nor_mj_xzdd_race_log AS ndnrl ON frl.races = ndnrl.id
		JOIN nor_mj_xzdd_race_player_log AS ndnrpl ON ndnrpl.race_id=ndnrl.id
WHERE 
		frpl.score < 0 AND frl.begin_time > @_start_time AND frl.end_time < @_end_time
		AND frl.game_type LIKE "nor_mj%"	AND ndnrpl.player_id = frpl.player_id
GROUP BY
	frl.game_id
;


SELECT 
(@_all_ddz_win_rate+@_all_mj_win_rate)/(@_all_ddz_win_p_num+@_all_mj_win_p_num)win_ave_rate,
(@_all_ddz_lose_rate+@_all_mj_lose_rate)/(@_all_ddz_lose_p_num+@_all_mj_lose_p_num) lose_ave_rate


;


END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for query_city_match_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `query_city_match_info`;
delimiter ;;
CREATE PROCEDURE `query_city_match_info`()
  SQL SECURITY INVOKER
BEGIN

	SET @hx_join_num = 0;
	SET @hx_promoted_num = 0;
	SET @hx_lose_num = 0;

	SET @fs_join_num = 0;
	SET @fs_promoted_num = 0;
	SET @fs_lose_num = 0;
	SET @baoming_count = 0;

	SELECT COUNT(*) into @hx_lose_num FROM zy_city_match_hx_lose WHERE player_id NOT LIKE "v%";
	SELECT COUNT(*) into @hx_promoted_num FROM zy_city_match_rank_hx WHERE player_id NOT LIKE "v%";
	SELECT @hx_lose_num + @hx_promoted_num INTO @hx_join_num;

	SELECT COUNT(*) into @fs_lose_num FROM zy_city_match_fs_lose WHERE player_id NOT LIKE "v%";
	SELECT COUNT(*) into @fs_promoted_num FROM zy_city_match_rank_fs WHERE player_id NOT LIKE "v%";
	SELECT @fs_lose_num + @fs_promoted_num INTO @fs_join_num;
	
	SELECT -sum(change_value) into @baoming_count FROM player_prop_log where change_type in ('match_signup','match_cancel_signup') and prop_type='zy_city_match_ticket_hx';
	
	SELECT 
	@hx_join_num as "海选总参与人数",
	@hx_promoted_num as "海选晋级人数",
	@hx_lose_num as "海选失败人数",
	@fs_join_num as "复赛参与人数",
	@fs_promoted_num as "复赛晋级人数",
	@fs_lose_num as "复赛失败人数",
	@baoming_count as "海选报名次数";


	SELECT * FROM zy_city_match_hx_lose WHERE player_id NOT LIKE "v%";
	SELECT * FROM zy_city_match_rank_hx WHERE player_id NOT LIKE "v%";

	SELECT * FROM zy_city_match_fs_lose WHERE player_id NOT LIKE "v%";
	SELECT * FROM zy_city_match_rank_fs WHERE player_id NOT LIKE "v%";

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for query_nor_ddz_nor_race_log_operation
-- ----------------------------
DROP PROCEDURE IF EXISTS `query_nor_ddz_nor_race_log_operation`;
delimiter ;;
CREATE PROCEDURE `query_nor_ddz_nor_race_log_operation`(`race_id` int)
  SQL SECURITY INVOKER
BEGIN

	SET @opts = "";

	SELECT operation_list into @opts FROM nor_ddz_nor_race_log WHERE id=race_id;

	SET @size = LENGTH(@opts);  
	SET @pos = 1;  
	SET @str = "";

	WHILE @pos<@size+1 DO  
					SET @c = SUBSTRING(@opts,@pos,1);
					SET @str = CONCAT(@str,",",ASCII(@c));
					SET @pos = @pos + 1;
	END WHILE; 
	
	SELECT @str;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for query_nor_lhd_nor_race_log_operation
-- ----------------------------
DROP PROCEDURE IF EXISTS `query_nor_lhd_nor_race_log_operation`;
delimiter ;;
CREATE PROCEDURE `query_nor_lhd_nor_race_log_operation`(`race_id` int)
  SQL SECURITY INVOKER
BEGIN

	SET @opts = "";

	SELECT operation_list into @opts FROM nor_lhd_nor_race_log WHERE id=race_id;

	SET @size = LENGTH(@opts);  
	SET @pos = 1;  
	SET @str = "";

	WHILE @pos<@size+1 DO  
					SET @c = SUBSTRING(@opts,@pos,1);
					SET @str = CONCAT(@str,",",ASCII(@c));
					SET @pos = @pos + 1;
	END WHILE; 
	
	SELECT @str;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for query_nor_mj_gobang_race_log_operation
-- ----------------------------
DROP PROCEDURE IF EXISTS `query_nor_mj_gobang_race_log_operation`;
delimiter ;;
CREATE PROCEDURE `query_nor_mj_gobang_race_log_operation`(`race_id` int)
  SQL SECURITY INVOKER
BEGIN

	SET @opts = "";

	SELECT operation_list into @opts FROM nor_gobang_nor_race_log WHERE id=race_id;

	SET @size = LENGTH(@opts);  
	SET @pos = 1;  
	SET @str = "";

	WHILE @pos<@size+1 DO  
					SET @c = SUBSTRING(@opts,@pos,1);
					SET @str = CONCAT(@str,",",ASCII(@c));
					SET @pos = @pos + 1;
	END WHILE; 
	
	SELECT @str;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for query_nor_mj_xzdd_race_log_operation
-- ----------------------------
DROP PROCEDURE IF EXISTS `query_nor_mj_xzdd_race_log_operation`;
delimiter ;;
CREATE PROCEDURE `query_nor_mj_xzdd_race_log_operation`(`race_id` int)
  SQL SECURITY INVOKER
BEGIN

	SET @opts = "";

	SELECT operation_list into @opts FROM nor_mj_xzdd_race_log WHERE id=race_id;

	SET @size = LENGTH(@opts);  
	SET @pos = 1;  
	SET @str = "";

	WHILE @pos<@size+1 DO  
					SET @c = SUBSTRING(@opts,@pos,1);
					SET @str = CONCAT(@str,",",ASCII(@c));
					SET @pos = @pos + 1;
	END WHILE; 
	
	SELECT @str;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for query_nor_pdk_nor_race_log_operation
-- ----------------------------
DROP PROCEDURE IF EXISTS `query_nor_pdk_nor_race_log_operation`;
delimiter ;;
CREATE PROCEDURE `query_nor_pdk_nor_race_log_operation`(`race_id` int)
  SQL SECURITY INVOKER
BEGIN

	SET @opts = "";

	SELECT operation_list into @opts FROM nor_pdk_nor_race_log WHERE id=race_id;

	SET @size = LENGTH(@opts);  
	SET @pos = 1;  
	SET @str = "";

	WHILE @pos<@size+1 DO  
					SET @c = SUBSTRING(@opts,@pos,1);
					SET @str = CONCAT(@str,",",ASCII(@c));
					SET @pos = @pos + 1;
	END WHILE; 
	
	SELECT @str;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sczd_activate_tglb
-- ----------------------------
DROP PROCEDURE IF EXISTS `sczd_activate_tglb`;
delimiter ;;
CREATE PROCEDURE `sczd_activate_tglb`(IN _player_id varchar(50)
	,OUT _tglb_award_cache int)
  SQL SECURITY INVOKER
BEGIN
	#Routine body goes here...

	-- declare p_tglb_award_cache int;
	
	select tglb_contribution_cache into _tglb_award_cache from sczd_activity_info where player_id = _player_id;

	-- set _tglb_award_cache = p_tglb_award_cache;
	-- select _tglb_award_cache;

	update sczd_activity_info set tglb_contribution_cache = 0 where player_id = _player_id;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sczd_change_parent
-- ----------------------------
DROP PROCEDURE IF EXISTS `sczd_change_parent`;
delimiter ;;
CREATE PROCEDURE `sczd_change_parent`(IN _player_id VARCHAR(50) 
, IN _new_parent_id VARCHAR(50))
  SQL SECURITY INVOKER
BEGIN
  #Routine body goes here...
	
	DECLARE old_parent_id VARCHAR(50) DEFAULT '';
	# 找旧上级
	SELECT parent_id into old_parent_id FROM sczd_relation_data WHERE id = _player_id;
	# 旧上级，son数量-1
	if old_parent_id and old_parent_id <> '' then
		UPDATE sczd_player_base_info SET all_son_count = all_son_count - 1 where player_id = old_parent_id;
	end if;	
	# 更新关系
	update sczd_relation_data set parent_id = _new_parent_id where id = _player_id;
	# 新上级，son数量+1
	UPDATE sczd_player_base_info SET all_son_count = all_son_count + 1 where player_id = _new_parent_id;
	# 我的总贡献清0
	update sczd_player_base_info set total_contribution_for_parent = 0 where player_id = _player_id;
	# 我的其他贡献 清0
	update sczd_activity_info set tglb_contribution_for_parent = 0,bbsc_contribution_for_parent = 0 where player_id = _player_id;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sczd_gjhhr_month_settle
-- ----------------------------
DROP PROCEDURE IF EXISTS `sczd_gjhhr_month_settle`;
delimiter ;;
CREATE PROCEDURE `sczd_gjhhr_month_settle`()
  SQL SECURITY INVOKER
BEGIN

	# 高级合伙人 月结算

	start transaction;	
	
	-- 结算退款（业绩的欠账）
	update sczd_player_all_achievements set tuikuan = if(all_achievements>=tuikuan,0,tuikuan-all_achievements);
	
	-- 清空业绩
	update sczd_player_all_achievements set  all_achievements=0,yesterday_all_achievements=0,yesterday_tuikuan = tuikuan;
	
	commit;	

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sczd_gjhhr_record_today_achievements
-- ----------------------------
DROP PROCEDURE IF EXISTS `sczd_gjhhr_record_today_achievements`;
delimiter ;;
CREATE PROCEDURE `sczd_gjhhr_record_today_achievements`()
  SQL SECURITY INVOKER
BEGIN

		declare _now datetime;

		start transaction;

		set _now = now();

		insert into sczd_player_day_achievements_log(id,achievements,tuikuan,all_achievements,all_tuikuan,time)
		select id,all_achievements-yesterday_all_achievements,tuikuan-yesterday_tuikuan,all_achievements,tuikuan,_now 
		from sczd_player_all_achievements 
		where all_achievements <> yesterday_all_achievements or tuikuan <> yesterday_tuikuan;

		update sczd_player_all_achievements set yesterday_all_achievements = all_achievements,yesterday_tuikuan=tuikuan;

		commit;	

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sp_login
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_login`;
delimiter ;;
CREATE PROCEDURE `sp_login`(_id varchar(50),

	login_ip varchar(50),

	login_os varchar(500))
  SQL SECURITY INVOKER
BEGIN
 
	start transaction;

 
	insert into player_login_log(id,login_ip,login_os) values(_id,login_ip,login_os);

	insert into player_login(id,login_ip,login_os,on_line,log_id) values(_id,login_ip,login_os,1,last_insert_id())
  on duplicate key update login_ip = login_ip,login_os=login_os,log_id = last_insert_id(),on_line=1,login_time = now(),logout_time=null;
       
	insert into player_login_stat(id,first_login_time,first_log_id,last_login_time,last_log_id) values(_id,now(),last_insert_id(),now(),last_insert_id())
  on duplicate key update last_login_time = now(),last_log_id=last_insert_id();
	
	update player_register set systype = if(login_os like '%iPhone%' or login_os like '%iOS%','ios',if(login_os like 'Android%','android','unknown')) 
	where id = _id and (systype = 'unknown' or systype is null);

  commit;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sp_logout
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_logout`;
delimiter ;;
CREATE PROCEDURE `sp_logout`(_ID varchar(50))
  SQL SECURITY INVOKER
BEGIN
    declare _log_id INT;
    
	start transaction;
    
    select log_id into _log_id from player_login where id = _ID and on_line=1 ;
    if FOUND_ROWS() > 0 then
		update player_login_log set logout_time = now() where log_id = _log_id;
		update player_login set logout_time = now(),on_line=NULL where id = _ID;
	end if;
        
    commit;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for statis_buried_point_ad_everyday_log
-- ----------------------------
DROP PROCEDURE IF EXISTS `statis_buried_point_ad_everyday_log`;
delimiter ;;
CREATE PROCEDURE `statis_buried_point_ad_everyday_log`()
  SQL SECURITY INVOKER
BEGIN
 
	#  第一步，把statistics_buried_point里面的关于 广告 的触发和观看的数据，统计到 statistics_buried_point_ad_everyday_log 里面
	
	start transaction;
	
	insert into statistics_buried_point_ad_everyday_log ( ad_id , trigger_num , trigger_player_num , watch_num , watch_player_num ) 
		select A.content , A.trigger_num,A.trigger_player_num , A.watch_num , A.watch_player_num 
			from 
		( select content , count(type = 'ad_trigger' or null) trigger_num, count(type = 'ad_show' or null) watch_num, count(DISTINCT CASE WHEN type='ad_trigger' THEN player_id END) as trigger_player_num , count(DISTINCT CASE WHEN type='ad_show' THEN player_id END) as watch_player_num from statistics_buried_point where type = 'ad_trigger' or type = 'ad_show' GROUP BY content ) A;
		
	#  第二步，把数据全部转移到 statistics_buried_point_log 里面 
	insert into statistics_buried_point_log ( player_id , type , content , time ) 
		select player_id , type , content , time from statistics_buried_point; 
	
	delete from statistics_buried_point;
	
  commit;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for statis_everyday_lose_func
-- ----------------------------
DROP PROCEDURE IF EXISTS `statis_everyday_lose_func`;
delimiter ;;
CREATE PROCEDURE `statis_everyday_lose_func`()
  SQL SECURITY INVOKER
BEGIN
 
 
	declare today VARCHAR(50) DEFAULT '';
	SET today =  date_format( FROM_UNIXTIME( (UNIX_TIMESTAMP(now()) - 86400 ) ) , "%Y-%m-%d" );
	
	start transaction;
	
	
	insert into player_statis_profit_log (player_id , yestoday_profit) 
	select E.id,
				IFNULL( (E.jing_bi - E.last_jing_bi) - ( E.sum_money - E.last_charge_sum ) * 100 + (E.shop_gold_sum + (E.dui_shiwu_gold - E.last_dui_shiwu_gold) - E.last_shop_gold_sum) * 100,0 ) from 
	(
				select A.id,
				IFNULL(A.jing_bi,0) as jing_bi,
				IFNULL(A.shop_gold_sum,0) as shop_gold_sum ,
				IFNULL(B.sum_money,0) as sum_money,
				(IFNULL(C.dui_shiwu_gold,0) + IFNULL(C.dui_xiaofei_gold,0)) as dui_shiwu_gold, 
				IFNULL(D.jing_bi, IFNULL(A.jing_bi,0) ) as last_jing_bi, 
				IFNULL(D.shop_gold_sum, IFNULL(A.shop_gold_sum,0) ) as last_shop_gold_sum, 
				IFNULL( D.total_charge, IFNULL(B.sum_money,0) ) as last_charge_sum , 
				IFNULL(D.dui_shiwu_gold,IFNULL(C.dui_shiwu_gold,0) + IFNULL(C.dui_xiaofei_gold,0) ) as last_dui_shiwu_gold 
				from player_asset A 
						left join player_pay_order_stat B on A.id = B.player_id 
						left join player_shop_gold_stat C on A.id = C.player_id 
						left join player_last_asset_map D on A.id = D.player_id 
						INNER JOIN player_login F on A.id = F.id and F.id not like 'robot_%' and F.login_time > today
	) E;
	
	insert into player_last_asset_map (player_id,jing_bi,shop_gold_sum,total_charge,dui_shiwu_gold)
	select A.id,IFNULL(A.jing_bi,0),IFNULL(A.shop_gold_sum,0),IFNULL(B.sum_money,0), IFNULL(C.dui_shiwu_gold,0) + IFNULL(C.dui_xiaofei_gold,0)
	from player_asset A 
		left join player_pay_order_stat B on A.id = B.player_id 
		left join player_shop_gold_stat C on A.id = C.player_id    
		INNER JOIN player_login F on A.id = F.id and F.id not like 'robot_%' and F.login_time > today
	on duplicate key update
		player_id = A.id,
		jing_bi = IFNULL(A.jing_bi,0),
		shop_gold_sum = IFNULL(A.shop_gold_sum,0),
		total_charge = IFNULL(B.sum_money,0),
		dui_shiwu_gold = IFNULL(C.dui_shiwu_gold,0) + IFNULL(C.dui_xiaofei_gold,0) ;

  commit;

END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for stat_club_total_consume
-- ----------------------------
DROP PROCEDURE IF EXISTS `stat_club_total_consume`;
delimiter ;;
CREATE PROCEDURE `stat_club_total_consume`()
  SQL SECURITY INVOKER
BEGIN
    -- 俱乐部的玩家消费总计表，每次统计 1000 条

    declare last_log_id int;
    set last_log_id = get_variant_int('last_club_total_consume_stat_id');
    begin
		declare _log_id int;
		declare _player_id varchar(50);
        declare _asset_type varchar(50);
		declare _change_type varchar(50);
		declare _change_value bigint;
        DECLARE done INT DEFAULT FALSE;
        
        declare _cur_log_id int;
        
		declare log_cursor cursor for select log_id,id,asset_type,change_type,change_value from player_asset_log where log_id > if(isnull(last_log_id),0,last_log_id) limit 0,1000;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        open log_cursor;
        log_cur_loop:loop
        
			fetch log_cursor into _log_id,_player_id,_asset_type,_change_type,_change_value;
            
			IF done THEN
				LEAVE log_cur_loop;
			END IF;           
            
            set _cur_log_id = _log_id;
            if _asset_type = 'diamond' then
            
				insert into club_total_consume(player_id,diamond,last_log_id) values(_player_id,_change_value,_log_id)
                on duplicate key update diamond=diamond+_change_value,last_log_id=_log_id;
                
			elseif _asset_type = 'shop_ticket' then
            
				insert into club_total_consume(player_id,shop_ticket,last_log_id) values(_player_id,_change_value,_log_id)
                on duplicate key update shop_ticket=shop_ticket+_change_value,last_log_id=_log_id;
                
			elseif _asset_type = 'cash' then
            
				insert into club_total_consume(player_id,cash,last_log_id) values(_player_id,_change_value,_log_id)
                on duplicate key update cash=cash+_change_value,last_log_id=_log_id;
                
			end if;
                        
            set done = false;
		end loop log_cur_loop;
		
		close log_cursor;
        
        if not isnull(_cur_log_id) then
			insert into system_variant(`name`,`value`,`descript`) values ('last_club_total_consume_stat_id',_cur_log_id,'俱乐部系统已统计的消费日志')
            on duplicate key update `value` = _cur_log_id;
        end if;
    end;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
