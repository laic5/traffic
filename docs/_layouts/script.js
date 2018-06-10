function createParagraph() {
    var p = document.createElement('p');
    p.textContent = 'Test';
    
    // add other tags to p tag 
    // p.appendChild(..)
    document.body.appendChild(p);
}

var buttons = document.querySelectorAll('button');

// loop over all the buttons, assuming more than 1 button
for (var i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener('click', createParagraph);
}