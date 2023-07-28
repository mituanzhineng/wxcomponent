package Comman

import (
	"fmt"
	"github.com/WeixinCloud/wxcloudrun-wxcomponent/Global"
	"github.com/WeixinCloud/wxcloudrun-wxcomponent/Utils"
	"testing"
)

func TestGetAccessToken(t *testing.T) {
	conf, err := Utils.LoadConf("../etc/config.json")
	if err != nil {
		_ = fmt.Errorf("%v", err)
		return
	}
	Global.Conf = conf
	_, err = GetAccessToken("", "")
	if err != nil {
		return
	}
}

func TestGetAnswer(t *testing.T) {
	conf, err := Utils.LoadConf("../etc/config.json")
	if err != nil {
		_ = fmt.Errorf("%v", err)
		return
	}
	Global.Conf = conf
	_, err = GetAccessToken("", "")
	if err != nil {
		return
	}
	GetAnswer("你是谁")
}

func TestDataCollate(t *testing.T) {
	var in = `
我是百度公司开发的人工智能语言模型，我的中文名是文心一言，英文名是ERNIE Bot，[我可以完成的任务包括知识问答，文本创作，知识推理，数学计算，代码理解与编写，作画，翻译等。] [内容来自ERNIE-Bot]
`
	out := DataCollate(in)
	fmt.Println(out)
}
