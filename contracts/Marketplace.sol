pragma solidity >=0.4.22 <0.9.0;

contract Marketplace {
  string public name;
  uint public productCount = 0;
  mapping(uint => Product) public products;

  struct Product {
    uint id;
    string name;
    uint price;
    address payable owner;
    bool purchased;
  }

  event ProductCreated(
    uint id,
    string name,
    uint price,
    address payable owner,
    bool purchased
  );

  event ProductPurchased(
    uint id,
    string name,
    uint price,
    address payable owner,
    bool purchased
  );

  constructor() {
    name = "Awesome Marketplace";
  }

  function createProduct(string memory _name, uint _price) public {
    // Check that name is valid
    require(bytes(_name).length > 0);
    // Check that price is valid
    require(_price > 0);
    // Increment product count
    productCount++;
    // Create product
    products[productCount] = Product(
      productCount,
      _name,
      _price,
      payable(msg.sender),
      false
    );
    // Emit event
    emit ProductCreated(
      productCount,
      _name,
      _price,
      payable(msg.sender),
      false
    );
  }

  function purchaseProduct(uint _id) public payable {
    // Get the product
    Product memory _product = products[_id];
    // Get the seller
    address payable _seller = _product.owner;
    // Validate the product id
    require(_product.id > 0 && _product.id <= productCount);
    // Require that there is enough Ether in the transaction to cover the cost
    require(msg.value >= _product.price);
    // Require that the product hasn't been purchased
    require(!_product.purchased);
    // Buyer and seller are not the same
    require(msg.sender != _seller);
    // Transfer the ownership of the product
    _product.owner = payable(msg.sender);
    // Mark the product as purchased
    _product.purchased = true;
    // Update the product
    products[_id] = _product;
    // Transfer the funds
    _seller.transfer(msg.value);
    // Emit event
    emit ProductPurchased(
      _id,
      _product.name,
      _product.price,
      payable(msg.sender),
      true
    );
  }
}