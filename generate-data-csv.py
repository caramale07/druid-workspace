import random
import faker
from datetime import datetime, timedelta

def generate_csv_files(num_products, num_customers, num_dates, num_sales):
    fake = faker.Faker()

    # Open files for writing
    with open("products.csv", "w") as p_file, open("customers.csv", "w") as c_file, open("dates.csv", "w") as d_file, open("sales.csv", "w") as s_file:
        
        # Generate Products Data
        products = []
        for i in range(1, num_products + 1):
            product_name = fake.word().capitalize()
            category = random.choice(["Electronics", "Clothing", "Food", "Books", "Toys"])
            price = round(random.uniform(5, 500), 2)
            products.append((i, price))  # Store for sales reference
            p_file.write(f"{i},{product_name},{category},{price}\n")

        # Generate Customers Data
        for i in range(1, num_customers + 1):
            customer_name = fake.name().replace("'", "")
            location = fake.city()
            age = random.randint(18, 80)
            c_file.write(f"{i},{customer_name},{location},{age}\n")

        # Generate Dates Data
        dates = []
        start_date = datetime(2020, 1, 1)
        for i in range(num_dates):
            date = start_date + timedelta(days=i)
            day_name = date.strftime('%A')
            month_name = date.strftime('%B')
            year = date.year
            dates.append(date.strftime('%Y-%m-%d'))  # Store for sales reference
            d_file.write(f"{date.strftime('%Y-%m-%d')},{day_name},{month_name},{year}\n")

        # Generate Sales Data
        for i in range(1, num_sales + 1):
            product_id = random.randint(1, num_products)
            customer_id = random.randint(1, num_customers)
            date_id = random.choice(dates)
            quantity = random.randint(1, 10)
            price = next(p[1] for p in products if p[0] == product_id)
            total_amount = round(quantity * price, 2)
            s_file.write(f"{i},{product_id},{customer_id},{date_id},{quantity},{total_amount}\n")

# Example: Adjust the number of rows as needed
num_products = 100000
num_customers = 200000
num_dates = 3650
num_sales = 1000000

generate_csv_files(num_products, num_customers, num_dates, num_sales)

print("CSV files generated successfully.")
