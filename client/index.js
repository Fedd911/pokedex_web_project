const API_URL ='http://localhost:8080/';

//testFetch();
getPokemons();

async function fetchData() {

  try {
    const pokemonName = document.getElementById("pokemonName").value.toLowerCase();
    const response = await fetch(`https://pokeapi.co/api/v2/pokemon/${pokemonName}`);

    if (!response.ok) {
      throw new Error("Could not fetch the pokemon");
    }

    const data = await response.json();
    const pokemonSprite = data.sprites.front_default;
    const imgElement = document.getElementById("pokemonSprite");
    

    imgElement.src = pokemonSprite;
    imgElement.style.display = "block";

    await insertPokemon(pokemonName, pokemonSprite);
  } 
  catch (error){
    console.error(error);
  }
}

async function insertPokemon(name, image) {
  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({name, image}),
    });
    if(!response.ok) {
      throw new Error (`Could not POST THE POKEMON AYO`);
    }
    
  } catch (error){
    console.error(error);
  }
  
}

async function getPokemons() {
  try {
    const response = await fetch(API_URL);
    if (!response.ok) {
      throw new Error ('Could not get the damn Pokemons');
    }
    const data = await response.json();
    return displayPokedex(data);
  } catch (error) {
    console.error(error);
  }
}

function displayPokedex(pokemons) {
  const pokemonList = document.getElementById('pokemonList');
    pokemonList.innerHTML = '';

    pokemons.forEach(pokemon => {
      const listItem = document.createElement('li');
      listItem.textContent = `${pokemon.name}`;
      const img = document.createElement('img');
      img.src = pokemon.image;
      img.alt = pokemon.name;
      listItem.appendChild(img);
      pokemonList.appendChild(listItem);
    });
}