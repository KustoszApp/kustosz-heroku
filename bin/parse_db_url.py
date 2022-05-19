#!/usr/bin/env python3

import json
import dj_database_url

line_template = "export DYNACONF_DATABASES__default__{key}='{value}'"

parsed_db_config = dj_database_url.config(conn_max_age=600, ssl_require=True)
for key, value in parsed_db_config.items():
    if key.lower() == "options":
        value = json.dumps(value)
        value = f"@json {value}"
    line = line_template.format(key=key, value=value)
    print(line)
