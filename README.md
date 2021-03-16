# Test multisite DNS create/update sync 

This is a simple bash script to create an A record and query another recursor and authorative for correct answer.

Note that two powerdns authorative are synced using Bucardo in master-master mode.

## Usage

1. Create spped.test zone in authorative
2. Allow nsupdate and Set TSIG keys for the zone
3. Set TSIG key in key.conf
4. Set authoratives and recursors address inside script
5. Set for loop rounds
6. Run the script with various TTL and sleep time
7. Check result files for any inconsistency between recursors and A record created or updated(0=record not matched)