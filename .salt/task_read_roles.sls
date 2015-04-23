{% set users = {} %}
{% set groups = {} %}

{% for usersdict in data.get('users', []) %}
{% for user, data in usersdict.items() %}
{% set userd = users.setdefault(user, {}) %}
{% do users.update({user: salt['mc_utils.dictupdate'](userd, data)}) %}
{% endfor %}
{% endfor %}

{% for groupsdict in data.get('groups', []) %}
{% for group, data in groupsdict %}
{% set groupd = groups.setdefault(group, {}) %}
{% do groups.update(group,
                    salt['mc_utils.dictupdate'](groupd, data)) %}
{% endfor %}
{% endfor %}

{% for dbext in data.databases %}
{% for db, dbdata in dbext.items() %}
{% set userd = users.setdefault(dbdata.user, {}) %}
{% set usergroups = userd.setdefault('groups', []) %}
{% set o = dbdata.get('owner', None) %}
{% if o is none  or (o != dbdata.user) %}
{% if not o %}
{% set o = db + '_owners' %}
{% endif %}
{% do groups.setdefault(o, {}) %}
{% if o not in usergroups %}
{% do usergroups.append(o) %}
{% endif %}
{% endif %}
{% if dbdata.get('password') %}
{% do users.update({
  dbdata.user: salt['mc_utils.dictupdate'](
             userd, {'password': dbdata.password})}) %}
{% endif %}
{% endfor %}
{% endfor %}
