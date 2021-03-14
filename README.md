# ICO
Blockchain Programmation

Email envoyé au prof le 14/03

## Installation de Truffle

* Téléchargement de Truffle et Ganache pour l'environnement de test
* `truffle init`

## Token ERC20
* Name : MarsToken
* Ticker : MARS
* Decimal number : 10 override de la fonction avec _setupDecimals

```
import PATH_TO_NODE_MODULE
// Hérite des functions implementées par OpenZeppelin
contract MyToken is ERC20, Ownable {

}
```

## Migration du contract vers Blockchain test

1. Création du fichier `2_myToken.js`

```
const MyToken = artifacts.require("MyToken");

// Ajouter pour deployement sur le testnet
const data = require('../secret.json');

module.exports = function (deployer, network, accounts) {
  deployer.deploy(MyToken, 10, 1000000, {from: data.address});
};

```
2. `truffle develop`
3. `migrate` pour migrer le contract sur le blockchain test
4. `var myToken = await myToken.deployed()` pour pouvoir interagir depuis la console vers le contrat
## Customer allow listing

* La fonction `setPhase` permet d'enregistrer le user dans le contract et lui donne la permission d'acheter des **MARS**
* le mapping `phase` permet de tracer les utilisateurs autorisés. Ils sont autorisés à acheter des tokens si le mapping renvoie une valeur autre que 0
* le modifier `allowUsers` permet de vérifier cette condition.
```
modifier allowUsers(address recipient_) {
        require(phase[recipient_] > 0, "you are not allowed to buy tokens");
        _;
    }
```

## Multi level distribution

Les entrées pour le listing sont controlés par le mapping `phase`
`phase` est un mapping address => uint8, par défault a 0 partout.

Les tiers sont distribués en fonction des arrivés sur le contract, premiers ajoutés, premiers servis.

Dans chaque tiers, on garde à la fois le nombre de token distribués pendant le tiers mais sur tout le contrat

```
function _getToken(uint256 amount_) 
internal 
allowUsers(msg.sender)
returns(uint256) {
        SafeMath.add(totalIssuedToken, amount_);
        if (phase[msg.sender] == 1) {

            transferFrom(owner(), msg.sender, 5000*amount_);
            SafeMath.add(tokenIssued[1], 5000*amount_);
            SafeMath.add(totalIssuedToken, 5000*amount_);
        }
        else if (phase[msg.sender] == 2) {
            transferFrom(owner(), msg.sender, 2000*amount_);
            SafeMath.add(tokenIssued[2], 20000*amount_);
            SafeMath.add(totalIssuedToken, 2000*amount_);
        }
        else if (phase[msg.sender] == 3) {
            transferFrom(owner(), msg.sender, 1000*amount_);
            SafeMath.add(tokenIssued[3], 1000*amount_);
            SafeMath.add(totalIssuedToken, 1000*amount_);
        }
    }
```

La fonction getToken utilise les modifiers pour vérifier que l'acheteur ait la permission d'acheter les tokens

Ensuite pour les phases, les 10 premiers ajoutés bénéficient du tier 1, les 90 prochains du tiers 2, etc...

Le mapping `tokenIssued` permet de garder une trace des tokens achetés pour chaque phase ainsi que globalement.


## Airdrop

La fonction airdrop permet de "offrir" des tokens à une adresse spécifique. Nous nous sommes mis d'accord lors de l'implémentation de la fonction pour que le total supply du token augmente à chaque airdrop.

```
function airdrop(address payable recipient_, uint256 amount_)
public 
payable
onlyOwner {
        _mint(recipient_, amount_);
        Airdrop(recipient_, amount_);
    }
```
`Airdrop(recipient_, amount_)` est un évenement qui est émis lors de la création de nouveau token.

```
    event Airdrop(address user, uint256 amount_);
```

Le totalSupply dans le constructeur, représente le nombre de token émis à la création du contract. Si des airdrops sont décidés alors ce total va augmenter.

De même il serait possible de réduire ce nombre de token dans le futur en utilisant la fonction `_burn` pour garder le totalSupply initial, **ce n'est pas implémenté**

## Deployement vers le testnet Rinkeby

1. Modification du fichier `truffle-config.js`
    * ajout du `network rinkeby`
    * Création d'un compte Infura pour avoir accès à une node Rinkeby

```
networks: {
  development: {
   host: "127.0.0.1",
   port: 8545,
   network_id: "*"
  },
  rinkeby: {
      provider: function() { 
       return new HDWalletProvider(secret.mnemonic, `https://rinkeby.infura.io/v3/` + secret.projectId, 1);
      },
      network_id: 4,
      gas: 4500000,
      gasPrice: 10000000000,
  }
 }
```
2. Récupération de la seed phrase Metamask
3. `truffle console --network rinkeby` pour se connecter aux nodes
4. `migrate` afin de deployer le contrat sur le testnet.
5. Interaction avec le contrat depuis [MyCrypto](myCrypto.com)
6. envoie de token sur l'adresse du prof: [transaction ici](https://rinkeby.etherscan.io/tx/0xf86d0676a7c2bd02de6c45e2ee27f43d2caa3d694468db8fd797f5df06e12cb5)
