import requests
from pyquery import PyQuery as pyq

s = requests.Session()
loginUrl = 'https://myportal.sutd.edu.sg/psp/EPPRD/'
queryString = {
	"cmd": "login",
	"languageCd": "ENG"
}
postData = {
	"timezoneOffset": "-480",
	"userid": "1001340",
	"pwd": "Sutd15041993"
}

r = s.post(loginUrl, params=queryString, data=postData, verify=False)

tableUrl = 'https://sams.sutd.edu.sg/psc/CSPRD/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.SSR_SSENRL_SCHD_W.GBL'
encodeData = 'ICAJAX=1&ICNAVTYPEDROPDOWN=1&ICType=Panel&ICElementNum=0&ICStateNum=3&ICAction=DERIVED_CLASS_S_SSR_REFRESH_CAL%2489%24&ICXPos=0&ICYPos=986&ResponsetoDiffFrame=-1&TargetFrameName=None&FacetPath=None&ICFocus=&ICSaveWarningFilter=0&ICChanged=-1&ICResubmit=0&ICSID=%2B5liKn09oxitDQ5zrxNeOylwaocJlL7onN8dZ%2F4j36U%3D&ICActionPrompt=false&ICTypeAheadID=&ICFind=&ICAddCount=&ICAPPCLSDATA=&DERIVED_SSTSNAV_SSTS_MAIN_GOTO$22$=9999&DERIVED_REGFRM1_SSR_SCHED_FORMAT$38$=W&DERIVED_CLASS_S_START_DT=15%2F09%2F2014&DERIVED_CLASS_S_MEETING_TIME_START=08%3A00&DERIVED_CLASS_S_MEETING_TIME_END=18%3A00&DERIVED_CLASS_S_SHOW_AM_PM$chk=Y&DERIVED_CLASS_S_SHOW_AM_PM=Y&DERIVED_CLASS_S_MONDAY_LBL$81$$chk=Y&DERIVED_CLASS_S_MONDAY_LBL$81$=Y&DERIVED_CLASS_S_THURSDAY_LBL$chk=Y&DERIVED_CLASS_S_THURSDAY_LBL=Y&DERIVED_CLASS_S_SUNDAY_LBL$chk=Y&DERIVED_CLASS_S_SUNDAY_LBL=Y&DERIVED_CLASS_S_SSR_DISP_TITLE$chk=Y&DERIVED_CLASS_S_SSR_DISP_TITLE=Y&DERIVED_CLASS_S_TUESDAY_LBL$chk=Y&DERIVED_CLASS_S_TUESDAY_LBL=Y&DERIVED_CLASS_S_FRIDAY_LBL$chk=Y&DERIVED_CLASS_S_FRIDAY_LBL=Y&DERIVED_CLASS_S_SHOW_INSTR$chk=Y&DERIVED_CLASS_S_SHOW_INSTR=Y&DERIVED_CLASS_S_WEDNESDAY_LBL$chk=Y&DERIVED_CLASS_S_WEDNESDAY_LBL=Y&DERIVED_CLASS_S_SATURDAY_LBL$chk=Y&DERIVED_CLASS_S_SATURDAY_LBL=Y&DERIVED_SSTSNAV_SSTS_MAIN_GOTO$102$=9999'

r = s.post(tableUrl, data=encodeData, verify=False)
d = pyq(r.content)
print(r.content)
def sprint(index, node):
	print(index, node.text_content())

d('span.SSSTEXTWEEKLY').each(sprint)