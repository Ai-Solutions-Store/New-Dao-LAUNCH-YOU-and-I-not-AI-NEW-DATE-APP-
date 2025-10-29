
import pandas as pd

# Create comprehensive product catalog with daily suggestions for anti-AI merch store
# Focus on profitable, premium items with Apple-style minimalism

product_catalog = {
    'Day': list(range(1, 31)),  # 30 days of product ideas
    'Product_Category': [
        'Apparel', 'Accessories', 'Home_Decor', 'Tech_Accessories', 'Apparel',
        'Drinkware', 'Apparel', 'Accessories', 'Stationery', 'Home_Decor',
        'Apparel', 'Tech_Accessories', 'Accessories', 'Drinkware', 'Apparel',
        'Home_Decor', 'Accessories', 'Tech_Accessories', 'Apparel', 'Drinkware',
        'Accessories', 'Home_Decor', 'Apparel', 'Stationery', 'Tech_Accessories',
        'Apparel', 'Accessories', 'Home_Decor', 'Drinkware', 'Apparel'
    ],
    'Product_Name': [
        'Premium Anti-AI Logo T-Shirt (Organic Cotton)',
        'Minimalist Anti-AI Enamel Pin Set',
        'Canvas Wall Art: "Human Made" Statement',
        'Anti-AI MacBook Sleeve (Premium Leather)',
        'Luxury Crewneck Sweatshirt with Embroidered Logo',
        'Insulated Stainless Steel Tumbler with Anti-AI Etching',
        'Premium Hoodie: "Powered by Humans"',
        'Anti-AI Leather Laptop Sticker Pack',
        'Minimalist Journal: "Human Thoughts Only"',
        'Framed Art Print: Anti-AI Manifesto',
        'Long Sleeve Tee: Prohibition Symbol Design',
        'Premium Phone Case: Anti-AI Symbol',
        'Luxury Tote Bag (Canvas/Leather Trim)',
        'Ceramic Coffee Mug: "Real Artists Only"',
        'Tank Top: Minimalist Anti-AI Statement',
        'Metal Wall Sign: Vintage Anti-AI Warning',
        'Premium Beanie with Embroidered Symbol',
        'Wireless Charging Pad with Anti-AI Engraving',
        'Zip-Up Hoodie: Premium Quality',
        'Water Bottle: Stainless Steel with Logo',
        'Leather Keychain: Anti-AI Tag',
        'Throw Pillow: "Human Creativity" Design',
        'Polo Shirt: Subtle Embroidered Logo',
        'Luxury Notebook Set (3-Pack)',
        'Premium Laptop Stand with Logo Plate',
        'Baseball Cap: Minimalist Embroidery',
        'Leather Wallet: Debossed Anti-AI Symbol',
        'Canvas Print: "Algorithm-Free Zone"',
        'Vacuum Insulated Wine Tumbler',
        'Performance T-Shirt: Moisture-Wicking'
    ],
    'Supplier_Cost': [
        12.50, 3.25, 18.00, 22.00, 18.00,
        8.50, 19.00, 4.50, 9.00, 25.00,
        13.00, 7.50, 11.00, 6.00, 10.00,
        15.00, 8.00, 12.00, 21.00, 9.50,
        5.00, 10.00, 16.00, 12.00, 28.00,
        9.00, 18.00, 20.00, 10.50, 11.50
    ],
    'Retail_Price': [
        49.99, 24.99, 89.99, 129.99, 89.99,
        39.99, 94.99, 29.99, 44.99, 149.99,
        54.99, 44.99, 69.99, 34.99, 39.99,
        79.99, 34.99, 64.99, 109.99, 44.99,
        29.99, 49.99, 74.99, 59.99, 149.99,
        39.99, 89.99, 119.99, 49.99, 44.99
    ],
    'Shipping_Cost': [
        4.50, 2.00, 8.00, 5.50, 5.00,
        4.00, 5.50, 2.50, 3.50, 9.00,
        4.50, 3.00, 4.50, 4.50, 4.00,
        7.00, 3.50, 3.50, 5.50, 4.50,
        2.00, 5.00, 5.00, 4.00, 6.00,
        3.50, 3.00, 8.00, 4.50, 4.50
    ]
}

df = pd.DataFrame(product_catalog)

# Calculate profit metrics
df['Total_Cost'] = df['Supplier_Cost'] + df['Shipping_Cost']
df['Gross_Profit'] = df['Retail_Price'] - df['Total_Cost']
df['Profit_Margin_%'] = ((df['Gross_Profit'] / df['Retail_Price']) * 100).round(2)

# Marketing channels for each product
marketing_channels = [
    'Instagram, Pinterest, TikTok',
    'Instagram, Etsy, Pinterest',
    'Pinterest, Instagram, Home Decor Blogs',
    'Reddit (r/mac), Instagram, Tech Forums',
    'Instagram, TikTok, Facebook',
    'Pinterest, Instagram, Lifestyle Blogs',
    'TikTok, Instagram, Reddit',
    'Instagram, Etsy, Tech Communities',
    'Pinterest, Book Communities, Instagram',
    'Pinterest, Art Communities, Instagram',
    'Instagram, TikTok, Streetwear Forums',
    'Instagram, Tech Forums, Reddit',
    'Pinterest, Instagram, Eco Fashion Blogs',
    'Instagram, Coffee Communities, Pinterest',
    'Instagram, TikTok, Fitness Communities',
    'Etsy, Pinterest, Home Decor Communities',
    'Instagram, TikTok, Streetwear',
    'Instagram, Tech Communities, Reddit',
    'Instagram, TikTok, Facebook',
    'Instagram, Fitness Communities, Pinterest',
    'Instagram, EDC Communities, Reddit',
    'Pinterest, Home Decor Blogs, Instagram',
    'Instagram, Golf Communities, Business',
    'Instagram, Stationery Communities, Etsy',
    'Instagram, Tech Communities, Productivity Blogs',
    'Instagram, TikTok, Streetwear',
    'Instagram, EDC Communities, Luxury Forums',
    'Pinterest, Instagram, Art Communities',
    'Instagram, Wine Communities, Pinterest',
    'Instagram, TikTok, Fitness Communities'
]

df['Marketing_Channels'] = marketing_channels

# Save to CSV
df.to_csv('anti_ai_merch_store_30day_catalog.csv', index=False)

print("30-Day Anti-AI Merch Store Product Catalog")
print("=" * 80)
print(f"\nTotal Products: {len(df)}")
print(f"Average Profit Margin: {df['Profit_Margin_%'].mean():.2f}%")
print(f"Average Gross Profit per Item: ${df['Gross_Profit'].mean():.2f}")
print(f"\nHighest Profit Items:")
print(df.nlargest(5, 'Gross_Profit')[['Day', 'Product_Name', 'Gross_Profit', 'Profit_Margin_%']])

print("\n" + "=" * 80)
print("\nFirst 10 Days Preview:")
print(df.head(10)[['Day', 'Product_Name', 'Retail_Price', 'Profit_Margin_%']].to_string(index=False))

print(f"\n\nFull catalog saved to: anti_ai_merch_store_30day_catalog.csv")
