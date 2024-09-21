# AI-Powered Flutter Food Search App

This Flutter project implements an AI-powered search functionality using **Gemini AI** and a **CSV** file to store food data. The search intelligently filters food items based on user queries such as item names, location, and availability time.

## Table of Contents

1. [Features](#features)
2. [Installation](#installation)
3. [How to Run](#how-to-run)
4. [Project Structure](#project-structure)
5. [Usage](#usage)
6. [Testing](#testing)
7. [Screenshots](#screenshots)
8. [License](#license)

## Features

- AI-powered search using **Gemini AI**.
- Real-time filtering of food items based on user queries.
- Handles search queries with item names, location, and availability time.
- Dynamic display of results with error handling for no matches.
- Simple and clean UI for searching and viewing food items.

## Installation

1. **Clone the repository**:

   ```bash
   [git clone https://github.com/your-repository-link.git](https://github.com/sarguru1981/AI_Flutter_Integration.git
   ```

2. **Navigate to the project directory**:

   ```bash
   cd ai_flutter_search_functionality
   ```

3. **Install Flutter dependencies**:

   Run the following command in the terminal:

   ```bash
   flutter pub get
   ```

4. **Set up the Gemini AI API key**:

   - You need an API key to use **Gemini AI**. Follow these steps:
     1. Obtain your API key from the [Google AI Platform](https://ai.google.com/).
     2. Create a `env.json` file in the root directory of your project.
     3. Add your API key like this:

       ```makefile
       {
        "api_key": your_gemini_api_key_here
       }
       ```

## How to Run

1. **Run the app** in your emulator or connected device using the following command:

   ```bash
   flutter run --dart-define-from-file=env.json
   ```

   Make sure to replace `your_gemini_ai_api_key_here` with your actual API key.

2. **Search functionality**:
   - Enter queries like “Show me pizzas available now in New York.”
   - Results will be dynamically filtered and displayed based on the AI's response.

## Project Structure

```bash
/ai_flutter_search_functionality
├── /assets          # To store your data and images
├── /android         # Android generated code
├── /iOS             # iOS generated code
├── /lib   
      ├──main.dart   # The main entry point for the app 
├── env.json         # API key storage
└── pubspec.yaml     # Dependencies related to the app
```

- **assets/dhaba_food_items.csv**: Contains the data for food items (Item Name, Category, Available Timing, Location).

## Usage

- **Search for food items**:
  Enter natural language queries like “Find burgers in Los Angeles” or “Show me food available now.” The app will filter items based on the **item name**, **location**, and **availability time**.

- **Example Queries**:
  - "Show me pizzas in San Francisco available at 7 PM."
  - "What food is available now?"

## Testing

To test the search functionality:

1. **Basic Queries**: Test simple queries like "Show me burgers."
2. **Advanced Queries**: Try more complex queries with time and location like "Show me pasta available now in New York."
3. **Edge Cases**: Test edge cases such as incomplete or ambiguous queries to see how the app handles them.
4. **Error Handling**: Test cases with no matching results (e.g., "Find sushi in Antarctica") to ensure the app displays "No results found."

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
