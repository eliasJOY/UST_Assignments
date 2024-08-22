class Expense:
    def __init__(self,expense_id,date,category,desc,amt):
        self.expense_id=expense_id
        self.date=date
        self.category=category
        self.desc=desc
        self.amt=amt

    def __str__(self):
        return (f"Expense ID:{self.expense_id} "
                f"Date:{self.date} "
                f"Category:{self.category} "
                f"Description:{self.desc} "
                f"Amount:{self.amt}")

expenses = []
def add_expense(expense):
    expenses.append(expense)

def update_expense(expense_id,new_expense):
    for i,expense in enumerate(expenses):
        if expense.expense_id == expense_id:
            expenses[i] = new_expense
            print(f"ExpenseID {expense_id} Updated")
            return
        print("Expense not found!")

def delete_expense(expense_id):
    for i,expense in enumerate(expenses):
        if expense.expense_id == expense_id:
            del expenses[i]
            print("ExpenseID {expense_id} deleted")
            return
        print("Expense not found!")

def display_expense():
    if not expenses:
        print("No Expenses")
    for expense in expenses:
        print(expense)

# User database

users={'elias123':'pass1','issac123':'pass2','anu123':'pass3'}

def authenticate_user(username,password):    
    if username in users and users[username] == password:
        print("Login Successful")
        return True
    else:
        print("Login Failed")
        return False

def categorize_expense():
    categories={}
    for exp in expenses:
        if exp.category in categories:
            categories[exp.category] +=exp.amt
        else:
            categories[exp.category] = exp.amt
    return categories
    
def summerize_expenses():
    total=0
    for exp in expenses:
        tot+=exp.amt
    return tot

def calculate_total_expenses():
    return sum(exp.amt for exp in expenses)

def generate_summmary_report():
    categories = categorize_expense()
    for category,amount in categories.items():
        print(f"Category:{category}, Total:{amount}")
    print(f"Total Expense:{calculate_total_expenses}")

def CLI():
    while True:
        print('''Expense Tracker
                1=>Login
                2=>Exit''')
        inp = int(input("Enter choice:"))
        if inp == 1:

            if not authenticate_user(input("Username: "),input("Password:")):
                print("User not authenticated")
                return
            while True:
                print('''\nTracker
                        1=> Add new expense
                        2=> Update expense
                        3=> Delete expense
                        4=> Display all expenses
                        5=> Generate expense summery
                        6=> Logout''')
                
                choice = int(input("Enter option:"))

                if choice == 1:
                    expense_id = input("ExpenseID:")
                    date = input("Date:")
                    category = input("Category:")
                    desc = input("Description:")
                    amt = float(input("Amount:"))
                    
                    add_expense(Expense(expense_id,date,category,desc,amt))

                elif choice == 2:
                    expense_id = input("ExpenseID to update:")
                    date = input("New date:")
                    category = input("New Category:")
                    desc = input("New Description:")
                    amt = float(input("New Amount:"))    

                    update_expense(expense_id,Expense(expense_id,date,category,desc,amt))

                elif choice == 3:
                    expense_id = input("ExpenseID to delete:")
                    delete_expense(expense_id)

                elif choice == 4:
                    display_expense()
                    
                elif choice == 5:
                    generate_summmary_report()

                elif choice == 6:
                    print("logging out...")
                    break
                else:
                    print("Choose a valid option")


        elif inp == 2:
            return
        else:
            print("Choose a valid option")

CLI()


