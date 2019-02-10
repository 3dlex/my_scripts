#!/usr/bin/env python3
#Description: Simple stock price grabber.
# User enters a stock ticker and we pull data from NASDAQ
# and pull the last sale price.
#
#Requires 
#Script needs requests and BeautifulSoup installed.
#
#Author: Matthew Davidson
#Date: 02-10-2019

#Imports
import requests
from bs4 import BeautifulSoup
import datetime

#Set the date
now = datetime.datetime.today().strftime('%Y-%m-%d')

#Ask user for stock ticker
ticker = input("Enter your stock ticker. Example: AMZN, MSFT, AAPL. ")

base_url = 'https://www.nasdaq.com/symbol/'
url = ''.join([base_url, ticker])
#Grab the page with the stock price
ticker_page = requests.get(url)

#Parse the page using BeautifulSoup so we can search
ticker_soup = BeautifulSoup(ticker_page.content, 'html.parser')

#Find the price using the div id for last sale price
ticker_price = ticker_soup.find_all(id="qwidget_lastsale")[0].get_text()

#Print the price
print(now + ':', ticker, 'last traded at', ticker_price + '.')

#Send data to log for future use
with open('ticker_logs.txt', mode='a') as file:
    file.write('%s,%s,%s\n' % (now,ticker,ticker_price))

#Tutorial on web scraping
#https://www.dataquest.io/blog/web-scraping-tutorial-python/
