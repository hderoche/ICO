# ICO
Blockchain Programmation

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

## Phases and getToken functions

phase est un mapping address => uint8, par défault a 0 partout.
si `phase[msg.sender] == 0` alors il n'est pas autorisé à acheter des tokens. Seul le propriétaire du contract a ce pouvoir.
```
function _getToken(uint256 amount_) 
internal 
allowUsers(msg.sender)
returns(uint256) 
    {
        SafeMath.add(totalIssuedToken, amount_);
        if (phase[msg.sender] == 1) {
            transferFrom(owner(), msg.sender, amount_);
            SafeMath.add(tokenIssued[1], amount_);
        }
        else if (phase[msg.sender] == 2) {
            transferFrom(owner(), msg.sender, amount_);
            SafeMath.add(tokenIssued[2], amount_);
        }
        else if (phase[msg.sender] == 3) {
            transferFrom(owner(), msg.sender, amount_);
            SafeMath.add(tokenIssued[3], amount_);

        }
        else revert();
    }
```

La fonction getToken utilise les modifiers pour vérifier que l'acheteur ait la permission d'acheter les tokens
```
modifier allowUsers(address recipient_) {
        require(phase[recipient_] > 0, "you are not allowed to buy tokens");
        _;
    }
```

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
        Airdrop(recipient_);
    }
```
`Airdrop(recipient_, amount_)` est un évenement qui est émis lors de la création de nouveau token.

```
    event Airdrop(address user, uint256 amount_);
```

Le totalSupply dans le constructeur, représente le nombre de token émis à la création du contract. Si des airdrops sont décidés alors ce total va augmenter.

De même il serait possible de réduire ce nombre de token dans le futur en utilisant la fonction `_burn` pour garder le totalSupply initial, **ce n'est pas implémenté**
