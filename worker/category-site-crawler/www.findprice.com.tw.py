import re
import urllib2
import pymongo

def striphtml(data):
    p = re.compile(r'<.*?>')
    return p.sub('', data)

def getHTML(url):
    return urllib2.urlopen(url).read()

def getUrlWithQueryAndPage(query, pageNum):
    return "http://www.findprice.com.tw/datalist.aspx?s=g&gn=12864&i=%d&q=%s&o=0""" % (pageNum, query)


ITEM_PATTENR = "<tr >\s*<td align='center' valign='middle' width='70px'>.*?</td></tr>"
ITEM_DETAIL_PATTERN = """<td align='center' valign='middle' width='70px'>\s*"""\
    """<a href='(.*?)'.*? src='(.*?)'.*?<font style='color:#ff0033;font-family:verdana;font-size:11pt;'>"""\
    """<b>(.*?)</b></font></td>.*target='_blank' class='ga'>(.*?)</a>.*"""\
    """</div>\s*(?:<font style='color:#009900'>)?([^>]*?)(?:&nbsp;-&nbsp;</font>)?"""\
    """<a href='datalist.aspx.*>(.*)</a>.*"""\
    """<font size='2' color='#009900'>&nbsp;-&nbsp;(\S*)\s*&nbsp;-&nbsp;"""

def getItemsFromPage(page):
    items_html = re.findall(ITEM_PATTENR,page, re.S)
    items = [] ;
    for item_html in items_html:
        item_data = list(re.findall(ITEM_DETAIL_PATTERN, item_html, re.S)[0])
        item_data[3] = striphtml(item_data[3])
        if item_data[4] == '' :
            item_data[4], item_data[5] = item_data[5], item_data[4]
        item = {
            "url":item_data[0],
            "image":item_data[1],
            "price":int(item_data[2]),
            "name":item_data[3],
            "merchant":item_data[4],
            "lastCheckDate":item_data[6],
            "tag": [],
            }
        if item_data[5] != '':
            item["tag"].append(item_data[5])
        items.append(item)

    return items

connection=pymongo.Connection('localhost',27017)
yhdDB = connection.yhd
itemsCollection = yhdDB.items
def insertItemIntoDB(item):
     itemsCollection.insert(item)
import time
for pageNum in range(2,1287):
    print pageNum
    time.sleep(1)
    page = getHTML(getUrlWithQueryAndPage("htc",pageNum))
    items = getItemsFromPage(page)
    for item in items:
        insertItemIntoDB(item)
        print item
    
