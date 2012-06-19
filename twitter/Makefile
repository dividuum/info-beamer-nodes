HASHTAG = \#gpn12

help:
	@echo "make install - install python environment into .env"
	@echo "make update  - update local content"
	@echo "make clean   - cleanup"

install: 
	virtualenv .env
	.env/bin/easy_install oauth2
	.env/bin/easy_install python-twitter

update:
	.env/bin/python update-tweets.py "$(HASHTAG)"

clean:
	rm -rf .env
	rm -rf profile-image*
	rm -f tweets.json
