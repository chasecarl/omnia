{% set am_vcpus = 10 %}
# TODO: salt['cmd.shell']('groupmems --list --group qubes')
#       https://forum.qubes-os.org/t/qubes-salt-beginners-guide/20126
{% set user = "andrey" %}
{% set cleanup_only_key = "cleanup_only" %}
# TODO: get the version dynamically
{% set debian_minimal = "debian-12-minimal" %}
{% set builder_networking_name = "builder-networking" %}
{% set app_manager_name = "app-manager" %}
{% set dev_name = "dev" %}
{% set policy_filepath = "/etc/qubes/policy.d/30-user.policy" %}
# inserting '\\n' before '$' didn't perform cleanup properly
{% set policy_pattern =  "^qubes.Filecopy \\* " + app_manager_name + " " + dev_name + " allow$" %}

{% if not pillar.get(cleanup_only_key) %}
debian-minimal-installed:
  qvm.template_installed:
    - name: {{ debian_minimal }}

builder-networking:
  qvm.vm:
    - name: {{ builder_networking_name }}
    - clone:
      - source: {{ debian_minimal }}
    - prefs:
      - label: blue

app-manager:
  qvm.vm:
    - name: {{ app_manager_name }}
    - present:
      - template: {{ builder_networking_name }}
      - label: orange
    - prefs:
      - vcpus: {{ am_vcpus }}

am-extended:
  cmd.run:
    - name: qvm-volume extend {{ app_manager_name }}:private 3GiB

am-firewall-configured:
  qvm.firewall:
    - name: {{ app_manager_name }}
    - set:
      # Emacs
      - 'action=accept dsthost=git.sv.gnu.org proto=tcp dstports=9418'
      - 'action=accept specialtarget=dns'
      # When editing the firewall with the GUI, the following is added
      # - 'action=accept proto=icmp'
      - 'action=drop'

dev:
  qvm.vm:
    - name: {{ dev_name }}
    - clone:
      - source: {{ debian_minimal }}
    - prefs:
      - label: blue

{{ policy_filepath }}:
  file.touch

am-to-dev-copy-policy:
  file.replace:
    - name: {{ policy_filepath }}
    - pattern: {{ policy_pattern }}
    # need to have the text here (and not group reference), as it won't work in case
    # of append
    - repl: "qubes.Filecopy * {{ app_manager_name }} {{ dev_name }} allow"
    - append_if_not_found: True

# TODO: it's kind of a 'forward declaration': before dev.sls finished running, there is
#       no 'emacs.desktop' entry, and you should run 'qvm-sync-appmenus' afterwards.
#       Ideally this state should just run after 'dev'.
#       Looks promising - check it out:
#       https://docs.saltproject.io/en/latest/topics/orchestrate/index.html
# TODO: just use qvm.vm.features.set.menut-items with 'qvm-appmenus --update'
#       afterwards?
#       https://forum.qubes-os.org/t/qubes-salt-beginners-guide/20126
dev-emacs-enabled-as-app:
  cmd.run:
    - stateful: True
    # TODO: I think the path should be relative to /srv/user_salt
    - name: >
        /srv/user_salt/scripts/appmenu-entry-in-whitelist.sh
        {{ dev_name }}
        emacs.desktop
{% endif %}

{% if pillar.get("cleanup") or pillar.get(cleanup_only_key) %}
cleanup-am:
  qvm.vm:
    - name: {{ app_manager_name }}
    - absent: pass
cleanup-bn:
  qvm.vm:
    - name: {{ builder_networking_name }}
    - absent: pass
cleanup-dev:
  qvm.vm:
    - name: {{ dev_name }}
    - absent: pass
cleanup-policy:
  file.replace:
    - name: {{ policy_filepath }}
    - pattern: {{ policy_pattern }}
    - repl: ""
    - ignore_if_missing: True
{% endif %}
