const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp(functions.config().firebase);

exports.generateRecipe = functions.https.onRequest(async (req, res) => {
    let indices = req.body.indices;
    let randomIndices = [];
    for (let i = 0; i < Math.min(5, 136 - indices.length); i++) {
        let randomIndex = Math.floor(Math.random() * 136);
        while (indices.includes(randomIndex) || randomIndices.includes(randomIndex)) {
            randomIndex = Math.floor(Math.random() * 136);
        }
        randomIndices.push(randomIndex);
    }

    const db = admin.firestore();

    let recipes = [];
    for (let i = 0; i < randomIndices.length; i++) {
        let recipe = await db.collection("recipes").where("index", "==", randomIndices[i]).get();
        recipes.push(recipe.docs[0].data());
    }

    res.json({recipes});
});

exports.indexRecipes = functions.https.onRequest(async (req, res) => {
    const db = admin.firestore();
    let recipes = await db.collection("recipes").get();
    let index = 0;
    recipes.forEach((recipe) => {
        recipe.ref.update({index: index});
        index++;
    });
    res.json({recipes});
});

exports.cleanupRecipes = functions.https.onRequest(async (req, res) => {
    const db = admin.firestore();
    let recipes = await db.collection("recipes").get();
    let recipeTitles = [];
    recipes.forEach((recipe) => {
        if (recipeTitles.includes(recipe.data().title)) {
            recipe.ref.delete();
            return;
        }
        if (recipe.data().title.length < 5 || recipe.data().ingredients.length === 0) {
            recipe.ref.delete();
        }
        recipeTitles.push(recipe.data());
    });
    res.json({recipes});
});

exports.cleanupInstructions = functions.https.onRequest(async (req, res) => {
    const db = admin.firestore();
    let recipes = await db.collection("recipes").get();
    recipes.forEach((recipe) => {
        let instructions = recipe.data().instructions;
        let newInstructions = [];
        for (let instruction of instructions) {
            // if instruction starts with ., remove it and trim string
            if (instruction.charAt(0) === ".") {
                newInstructions.push(instruction.substring(1).trim());
            } else {
                newInstructions.push(instruction.trim());
            }
        }
        recipe.ref.update({instructions: newInstructions});
    });
});
