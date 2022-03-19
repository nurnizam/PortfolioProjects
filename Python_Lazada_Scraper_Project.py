from bs4 import BeautifulSoup
import requests
import time
from datetime import datetime
import csv
import pandas as pd
import smtplib
import os.path
import sys

filepath = 'r"FILE PATH OF CSV FILE TO RECORD PRICE SCRAPED"'
try:
	filepath
except:
	open(filepath,'w', newline='', encoding='UTF8')

url = "LAZADA URL OF ITEM BEING MONITORED"

def countdown(t):
	while t:
		m, s = divmod(t, 60)
		h, m = divmod(m, 60)
		timer = '{:02d}:{:02d}:{:02d}'.format(h, m, s)
		print(timer + " before next price check. ** CTRL+C to stop program **", end="\r")
		time.sleep(1)
		t -= 1
	else:
		print("", end="\r")

## Automatic Scrape and Update ##

def check_price(url):
	global price, title
	try:
		headers = {"GET YOUR USER AGENT FROM httpbin.org/get"}

		page = requests.get(url, headers = headers)

		soup1 = BeautifulSoup(page.content, 'html.parser')
		soup2 = BeautifulSoup(soup1.prettify(), 'html.parser')

		title = soup2.find(id='module_product_title_1').get_text().strip()
		price = soup2.find('span', {'class':'pdp-price pdp-price_type_normal pdp-price_color_orange pdp-price_size_xl'}).text.strip()
		price = float(price.replace(',','')[1:])

		now = datetime.now()
		dt_now = now.strftime("%d/%m/%Y %H:%M:%S")
		today = datetime.today()
		header = ['Item','Price','Date']
		data = [title, price, today]

		if os.path.isfile(filepath):
			with open(filepath,'a+', newline='', encoding='UTF8') as f:
				writer = csv.writer(f)
				writer.writerow(data)
		else:
			with open(filepath,'w', newline='', encoding='UTF8') as f:
				writer = csv.writer(f)
				writer.writerow(header)
				writer.writerow(data)

		df = pd.read_csv(filepath)

		try:
			if df["Price"].iloc[-1] < df["Price"].iloc[-2]:
				try:
					send_mail()
					print('\nCSV file updated on {}. Email sent.'.format(dt_now))
				except:
					print('\nCSV file updated on {}. Email skipped.'.format(dt_now))
				countdown(43200)
			else:
				print('\nCSV file updated on {}. Email skipped.'.format(dt_now))
				countdown(43200)
		except:
			print('\nCSV file updated on {}. Email skipped.'.format(dt_now))
			countdown(43200)


	except (Exception, KeyboardInterrupt) as e:
		print(e)
		try:
			sys.exit(0)
		except SystemExit:
			os._exit(0)

### END SECTION ###

### OPTIONAL: Set Up Auto-Send Email Account ###

def send_mail():
	gmailaddress = 'SENDER GMAIL ADDRESS'
	gmailapppassword = 'SENDER GMAIL APP PASSWORD'
	receipentemailaddress = 'RECEIPENT EMAIL ADDRESS'

	server = smtplib.SMTP_SSL('smtp.gmail.com',465)
	server.ehlo()
	server.login(gmailaddress,gmailapppassword)

	subject = f"The Price of {title} Just Dropped!!!"
	body = f"The Price of {title} has dropped to {price}. Check it out.\n\n{url}"

	msg = f"subject: {subject}\n\n{body}"

	server.sendmail(gmailaddress, receipentemailaddress, msg)

### END SECTION ###

while(True):
	check_price(url)
	time.sleep(86400) # Wait for 12 hours before checking price again