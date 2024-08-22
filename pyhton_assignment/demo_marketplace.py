import random

#User and Admin databases
user_db = {'user1':'pass1','user2':'pass2','user3':'pass3'}
admin_db = {'admin1':'pass1','admin2':'pass2'}

def user_login():
    username = input("Enter username:")
    password = input("Enter password:")

    if username in user_db and user_db[username] == password:
        print("Login Successful as User")
        return True
    else:
        print("Login Failed")
        return False

def admin_login():
    username = input("Enter username:")
    password = input("Enter password:")

    if username in admin_db and admin_db[username] == password:
        print("Login Successful as Admin")
        return True
    else:
        print("Login Failed")
        return False

def generate_session_id():
    sessionID = random.randint(1000,2000)
    return sessionID


catlog = [{'id':111,'name':'Krack jack','category':'food','price':20},
          {'id':121,'name':'Galaxy S23','category':'electronics','price':55000},
          {'id':131,'name':'USPA polo','category':'clothing','price':5000},
          {'id':141,'name':'Mac air 3','category':'electronics','price':80000},
          {'id':151,'name':'Nike shirt','category':'clothing','price':2000},
          {'id':111,'name':'Cheese pizza','category':'food','price':200},
          {'id':111,'name':'Air pods','category':'electronics','price':20000}]

def display_catlog():
    print("\nProduct Catalog:")
    for item in catlog:
        print(f"ID:{item['id']}, Name:{item['name']}, Category:{item['category']}, Price:Rs.{item['price']}")

cart = []
def display_cart():
    if not cart:
        print("\nYour Cart is Empty")
    else:
        print("\nYour Cart has:")
        for item in cart:
            print(item)

def add_to_cart(sessionID,productID,qty):
    for product in catlog:
        if product['id'] == productID:
            item = {'SessionID':sessionID, 'ProductID':productID,'Name':product['name'], 'Quantity':qty}
            cart.append(item)
            print(f"Addes {qty} of {product['name']} to your Cart")
            return
        print("Product not found!")
 
def delete_from_cart(sessionID,productID):
    for item in cart:
        if item['productID'] == productID and item['SessionID'] == sessionID:
            cart.remove(item)
            print(f"Removed {item['Name']} from Cart")
            return
        print("Item not found in Cart")


def checkout():
    print('''Checkout
            1=>Net Banking
            2=>PayPal
            3=>UPI Payment''')
    
    pay_method = int(input("\nEnter payment method :"))
    if pay_method==1:
        print("Payment initiated through Net Banking")
    
    elif pay_method==1:
        print("Payment initiated through PayPal")
    
    elif pay_method==2:
        print("Payment initiated through UPI")
    else:
        print("Invalid payment method")
    print("Order is succesfully placed")

def add_product():
    productID = int(input("Enter productID:"))
    productName = input("Enter Product Name:")
    productCat = input("Enter Product category:")
    productPrice = int(input("Enter Product price:"))

    newProd = {'id':productID, 'name':productName, 'category':productCat, 'price':productPrice}

    catlog.append(newProd)
    print(f"New product {productName} added")

def update_product():
        productID = int(input("Enter productID:"))
        for product in catlog:
            if product['id'] == productID:
                product['name'] = input("Enter new productID:")
                product['category'] = input("Enter new category:")
                product['price'] = input("Enter new price:")

                print(f"Product Updated")
                return
        print("Product not found!")

def remove_product():
    productID = int(input("Enter productID:"))

    for product in catlog:
        if product['id'] == productID:
            catlog.remove(product)
            print(f"Product removed")
            return
    print("Product not found!")
    

def admin_func():
    print('''Admin Functions
            1=> Add Products
            2=> Updating Products
            3=> Remove products
            4=> LogOut''')
           
    choice=int(input("\nEnter choice:"))

    if choice == 1:
        add_product()
    elif choice == 2:
        update_product()
    elif choice == 3:
        remove_product()
    elif choice == 4:
        print("Logging out...")
        return
    else:
        print("Invalid choice")


#main program

print("Welcome to the Demo Marketplace")

while True:    
    choice = input("Are you a USER or an ADMIN : ")

    if str.lower(choice) == "user":
        if user_login():
            sessionID = generate_session_id()
            while True:
                print('''Choose Option
                        1=> View Cart
                        2=> Add to Cart
                        3=> Delete from Cart
                        4=> View Catlog
                        5=> Checkout
                        6=> LogOut''')
                inp = int(input("Enter choice:"))

                if  inp == 1:
                    display_cart()
                elif inp == 2:
                    add_to_cart()
                elif inp == 3:
                    delete_from_cart()
                elif inp == 4:
                    display_catlog()
                elif inp == 5:
                    checkout()
                    break
                elif inp == 6:
                    print("Logging Out...")
                    break
                else:
                    print("Invalid choice")
        else:
            print("....")

     
    elif str.lower(choice) == "admin":

        if admin_login():
            admin_func()
        
        else:
            print("....")
    elif str.lower(choice) == "exit":
        print("Exiting...")
        break
    else:
        print("Enter a valid choice or to exit enter (exit)")
        





