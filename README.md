Kustosz on Heroku

- describe files and what they do
- deployment - after deploying, you need `heroku config:set DYNACONF_ALLOWED_HOSTS='["myherokuappname.herokuapp.com"]'`
- fill in app.json
- describe variables - or mentioning in app.json is enough?
- once I have app.json, can I just clone && deploy?
- link to docs
- stress out this is designed to run on free plan
- some musing how to prepare repo that would scale
- describe what needs to be changed and when
- container - update entrypoint with changes here, update docs



```
poetry export -E heroku -o ../kustosz-heroku/requirements.txt && poetry version |sed -e 's: :==:' >> ../kustosz-heroku/requirements.txt
```
