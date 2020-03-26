credhub find -n / | grep -o '/.*unseal/.*' | head -n3 | xargs -n1 credhub get -n  | grep value: | cut -d' ' -f2
