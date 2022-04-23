const Band = require("./band");

class Bands {
  constructor() {
    this.bands = [];
  }

  getBands() {
    return this.bands;
  }

  addBand(band = new Band) {
    this.bands.push(band);
  }

  deleteBand(id = '') {
    this.bands = this.bands.filter(band => band.id != id);
    return this.bands;
  }
  
  voteBand(id = ''){
    /// Forma 1
    const index = this.bands.findIndex(band => band.id == id);
    this.bands[index].votes++;

    /// Forma 2 
    // this.bands = this.bands.map(band => {
    //   if(band.id == id){
    //     band.votes++
    //     return band /// Se retorna el mismo objeto pero aumentado
    //   } else {
    //     return band /// Se retorna el mismo objeto pero sin modificar
    //   }
    // })    
  }
}

module.exports = Bands;