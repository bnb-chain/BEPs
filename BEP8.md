# BEP8: Threshold Signature Scheme (TSS) in Binance Chain

## Summary
This BEP is about introducing the threshold signature scheme (TSS) in Binance Chain by adding an extra binary.

## Abstract
**Threshold Signature Scheme (TSS)** is a cryptographic protocol for distributed key generation and signing. TSS allows constructing a signature that is distributed among different parties (for example three users), and each user receives a share of the private signing key. To sign a transaction, at least two of these three users need to join. For individuals, threshold signatures allow for two-factor security or splitting the ability to sign between two devices so that a single compromised device won’t put the money at risk. For businesses, threshold signatures allow for the realization of access control policies that prevent both insiders and outsiders from stealing corporate funds. TSS technology allows us to replace all signing commands with distributed computations.The private key is no longer a single point of failure.

## Status
DRAFT

## Motivation
A physical key must fit exactly into a keyhole to unlock a physical vault. But if this key is compromised or lost, the funds locked in the vault may no longer be safe. This simple approach of key management may make sense when a small sum is at stake. However, when the amount stored in the vault is large, it is wise to consider spreading the responsibility of key ownership between several trusted parties.

Traditional **MultiSig (multi-signature)** is a more refined unlocking system that requires *multiple* independent keys to unlock the vault. MultiSig requires generating a larger private key and the vault has multiple locks - one for each key . More processing power is needed as participants have to sign additional signatures, which must then be checked individually by the network. This is not ideal, because a participant must leave traces showing exactly who signed and multiple parties must be online at the same time.

With **Threshold Signatures**, all of the parties must forge the vault’s lock together, in a modular way, where each party owns a share of the key. A TSS vault is indistinguishable from a regular vault and is hence universal, and it has the same privacy and verification cost of a regular vault. Even if only a subset of the keys is available, the vault may still be unlocked (this is known as meeting a threshold of participation).

On Binance Chain, the new TSS feature will help users manage their funds in a much safer way. TSS will be offered in an independent binary, but it will have some impact on the existing functions of *bnbcli/tbnbcli*.

## Specification

### Threshold Signature Scheme (TSS) Binary
The TSS binary relies on P2P network and it can be deployed in WAN/LAN with a centralized Bootstrap or Relay server or without. In the first release of the TSS binary, It will support running on a LAN.
*Where can I download the Binance TSS Binary?*
* You can download the TSS client from: <https://github.com/binance-chain/node-binary/tss>

## Workflow
Let’s take a look at the major steps in TSS:
* **Key Generation**: the first step is also the most complex. We need to define the quorum policy: count of total parties (n) that holds secret shares and threshold (t) which means at least t + 1 parties need to take part in the signing process. We need to generate a key which will be public and used to verify future signatures. However, we also have to generate an individual secret for each party, which is called a secret share. The functions guarantee the same public key to all parties and a different secret share for each. In this way, we achieve: (1) privacy: no secret shares data is leaked between any parties, and (2) correctness: the public key is intact with secret share.

* **Signing**: this step involves a signature generation function. The input of each party will be its own secret share, created as output of the distributed key generation in the previous step. There is also public input known to all, which is the message to be signed. The output will be a digital signature, and the property of privacy ensures that no leakage of secret shares occurred during the computation.

* **Verification**: the verification algorithm remains as it is in the classical setting. To be compatible with single key signatures, Binance Chain validator nodes can be able to verify the signature with the public key. The transaction will be no different from others.

The following diagram demonstrates total parties=3& threshold =1, deployment, i.e., 3 participants for the keygen and any 2 or 3 of these participants can do the signing, and one signature will be broadcast to the Binance Chain Successfully.

![img](https://lh3.googleusercontent.com/JmrMjUgE6P13PUl89mnqlB9XtybQWdbUJFdBoTEkkflF7XAQC3KrlLKqXzr3Jdm4Uq9uGsYFz_ylHEbwvkYCR16fqva5ovOepMkPuieV5ApRyGuagMy6eQssBNS9UfA2G053aRKL)

## TSS Binary Commands
Here are the global transaction flags:

| Name       | Type   | Description                                                  | Note                                              |
| ---------- | ------ | ------------------------------------------------------------ | ------------------------------------------------- |
| vault_name | string | name of the vault of this party                              |                                                   |
| password   | string | the password of the vault                                    | must be 32 bytes or more, the default value is 48 |
| home       | string | Path to config/route_table/node_key/tss_key files, configs in config file can be overridden by command line argument | the default value is "~/.tss"                     |

### Init

`tss init` will create home directory of a new tss setup, generate p2p key pair.

| Name       | Type   | Description                                                  | Note                                              |
| ---------- | ------ | ------------------------------------------------------------ | ------------------------------------------------- |
|kdf.iterations	|uint32	| The number of iterations (or passes) over the memory.|	the default value is 13|
|kdf.key_length|	uint32|	 Length of the generated key (or password hash)	"must be 32 bytes or more, |the default value is 48"|
|kdf.memory	|uint32|	The amount of memory used by the algorithm (in kibibytes) 	|the default value is 65536|
|kdf.parallelism	|uint8	|The number of threads (or lanes) used by the algorithm.|	the default value is 4|
|kdf.salt_length	|uint32|	Length of the random salt. 16 bytes is recommended for password hashing.	|the default value is 16|
|moniker	|string	|moniker of current party	||
|p2p.listen	|string	 |Adds a multiaddress to the listen list	||

* Example
```
./tss init
> please set moniker of this party:
tss1
> please set vault of this party:
vault1
> please set password of this vault:
1234
> please input again:
1234
```

### Channel

`tss channel` will generate a channel id for bootstrapping. One party can generate a channel, then share the generated channel ID with others.

| Name       | Type   | Description                                                  | Note                                              |
| ---------- | ------ | ------------------------------------------------------------ | ------------------------------------------------- |
|channel_expire|int|expire time in minutes of this channel||

* Example
```
./tss channel
> please set expire time in minutes, (default: 30):
[Enter]
channel id: 3085D3EC76D
```
3. Keygen

This command will generated the private key and share the secret.

Note: you need to make sure that all the parties are online.


| Name       | Type   | Description                                                  | Note                                              |
| ---------- | ------ | ------------------------------------------------------------ | ------------------------------------------------- |
|address_prefix|string|prefix of bech32 address|the default value is bnb|
|channel_id|string|channel id of this session||
|channel_password|string|password to this channel||
|p2p.peer_addrs|[]sting|peer's multiple addresses||
|parties|int|total parities of this scheme||
|threshold|int|threshold of this scheme, at least threshold + 1 parties need participant signing||

* Example
```
./tss keygen --vault_name vault1
> Password to sign with this vault:
1234
> Do you like re-bootstrap again?[y/N]:
[Enter]
> please set total parties(n):
3
> please set threshold(t), at least t + 1 parties  need participant signing:
1
> please set channel id of this session
3085D3EC76D
please input password (AGREED offline with peers) of this session:
123456789
Password of this tss vault: 1234qwerasdf
18:00:09.777  INFO    tss-lib: party {0,tss1}: keygen finished! party.go:113
18:00:09.777  INFO        tss: [tss1] received save data client.go:304
18:00:09.777  INFO        tss: [tss1] bech32 address is: tbnb1mcn0tl9rtf03ke7g2a6nedqtrd470e8l8035jp client.go:309
Password of this tss vault:
NAME:   TYPE:   ADDRESS:                                                PUBKEY:
tss_tss1_vault1        tss     tbnb19277gzv934ayctxeg5k9zdwnx3j48u6tydjv9p     bnbp1addwnpepqwazk6d3f6e3f5rjev6z0ufqxk8znq8z89ax2tgnwmzreaq8nu7sx2u4jcc

Output
You should see the generated files in the home folder
~/.tss/vault1/pk.json
~/.tss/vault1/sk.json
~/.tss/vault1/config.json
```

if you want to add the generated key files in the bnbcli home, you can copy it to the home folder:
```
bnbcli keys add --tss -t tss --tss-home ~/.test1 --tss-vault third test1_third
```

### Regroup
This command will generate new_n secrete from the same private key, and it will be shared with new_t threshold. At least old_t + 1 should participante in signing

| Name       | Type   | Description                                                  | Note                                              |
| ---------- | ------ | ------------------------------------------------------------ | ------------------------------------------------- |
|address_prefix|string|prefix of bech32 address|the default value is bnb|
|channel_id|string|channel id of this session||
|is_new_member|string|whether this party is new committee, for new party it will changed to true automatically. if an old party set this to true, its share will be replaced by one generated one||
|new_parties|int|new total parties of regrouped scheme||
|new_threshold|int|new threshold of regrouped scheme||
|p2p.new_peer_addrs|[]sting|unknown peer's multiple addresses||
|parties|int|total parities of this scheme||
|threshold|int|threshold of this scheme, at least threshold + 1 parties  need participant signing||


## Changes to `bnbcli/tbnbcli`
We added a new key type “tss” (just like the existing types: “local”, “offline”, “ledger”) to bnbcli which stands for tss secret share.

To add a tss key into bnbcli’s keystore:
1. Tss keygen command will automatically add generated secret share into default keystore (~/.bnbcli) with name “tss_<moniker>_<vault_name>”
2. User can manually specify tss’s home, vault_name and a customized bnbcli home like:
```
bnbcli keys add --home ~/.customized_cli --tss -t tss --tss-home ~/.test1 --tss-vault “default” my_name
```
All other commands (i.e. send token, place order, delete key etc.) of bnbcli should support tss type key.

## License
The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
