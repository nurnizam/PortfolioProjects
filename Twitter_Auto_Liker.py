import tweepy
import time
import os
import sys

### START OF USER ENTRY SECTION ###

consumer_key = 'ENTER CONSUMER KEY HERE'
consumer_secret = 'ENTER CONSUMER SECRET KEY HERE'
access_token = 'ENTER ACCESS TOKEN HERE'
access_token_secret = 'ACCESS TOKEN SECRET KEY HERE'

### END OF USER ENTRY SECTION ###


def countdown(t):
	while t:
		mins, secs = divmod(t, 60)
		timer = '{:02d}:{:02d}'.format(mins, secs)
		print(timer + " before liking next tweet. ** CTRL+C to stop program **", end="\r")
		time.sleep(1)
		t -= 1
	else:
		print("", end="\r")

auth = tweepy.OAuth1UserHandler(consumer_key, consumer_secret, access_token, access_token_secret)
api = tweepy.API(auth)
username = api.verify_credentials().screen_name

search = input('\nWhat kind of tweets do you want to like? \n')
tweets = tweepy.Cursor(api.search_tweets, search + ' -filter:retweets').items(500)
language = input("\nEnter 'e' if you want tweets only in English. Otherwise, enter any other character.\n")

for index, tweet in enumerate(tweets):
	try:
		if tweet.in_reply_to_status_id is not None or tweet.user.id == username:
			continue
		else:
			if language == 'e':
				if tweet.lang == 'en':
					os.system('cls')
					print("Liking tweets mentioning '" + search + "' in English language only.\n")
					print(f'>> Tweet Liked!: {tweet.text}\n')
					tweet.favorite()
					countdown(60)
			else:
				os.system('cls')
				print("Liking tweets mentioning '" + search + "' in any language.\n")
				print(f'>> Tweet Liked!: {tweet.text}\n')
				tweet.favorite()
				countdown(60)
	except (Exception, KeyboardInterrupt) as e:
		print(e)
		try:
			sys.exit(0)
		except SystemExit:
			os._exit(0)
