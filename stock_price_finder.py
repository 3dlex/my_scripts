#!/usr/bin/env python3
#Description: Simple stock price grabber. 
# Variation of stock_price.py
# Variable set with stocks ticker that I want to trend over time.
# We pull data from NASDAQ using the the last sale price.
#
#Requires 
#Script needs requests and BeautifulSoup installed.
#
#Author: Matthew Davidson
#Date: 03-02-2019
#Imports
import requests
from bs4 import BeautifulSoup
import datetime

#Set file to log information
path = "/home/matthew/bin/PythonTheHardWay/ticker_logs.csv"
#Set the date
now = datetime.datetime.today().strftime('%Y-%m-%d')
#Set stock ticker
ticker = ["AMZN", "MSFT", "KO", "AAPL"]

for stock in ticker:
    base_url = 'https://www.nasdaq.com/symbol/'
    url = ''.join([base_url, stock])
    #Grab the page with the stock price
    ticker_page = requests.get(url)
    #Parse the page using BeautifulSoup so we can search
    ticker_soup = BeautifulSoup(ticker_page.content, 'html.parser')
    
    #Find the price using the div id for last sale price
    ticker_price = ticker_soup.find_all(id="qwidget_lastsale")[0].get_text()
    
    #Print the date, stock ticker and price for the user
    #print(f'{now}: {stock} last traded at {ticker_price}.')
    
    #Send data to log for future use
    with open(path, mode='a') as file:
        file.write('%s,%s,%s\n' % (now,stock,ticker_price))    