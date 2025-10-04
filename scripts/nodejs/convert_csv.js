/**
 * Example: CSV to JSON conversion with Node.js
 */
const csvtojson = require('csvtojson');
const fs = require('fs');
const path = require('path');

async function convertCsvToJson(inputFile, outputFile) {
    console.log(`📊 Converting ${inputFile} to JSON...`);
    
    try {
        // Convert CSV to JSON
        const jsonArray = await csvtojson().fromFile(inputFile);
        
        // Create output directory if needed
        const outputDir = path.dirname(outputFile);
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }
        
        // Write JSON file
        fs.writeFileSync(
            outputFile, 
            JSON.stringify(jsonArray, null, 2)
        );
        
        console.log(`✅ Converted ${jsonArray.length} rows`);
        console.log(`   Output: ${outputFile}`);
        
    } catch (error) {
        console.error(`❌ Error: ${error.message}`);
        process.exit(1);
    }
}

// Main
const inputFile = process.argv[2] || 'data/raw/input.csv';
const outputFile = process.argv[3] || 'data/output/result.json';

convertCsvToJson(inputFile, outputFile);
