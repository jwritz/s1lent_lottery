var buttons = [];
var selectedCount = 0;

// These counts are the number of numbers show for a lottery
// in the order they appear in the dropdown menu.
// (Zero based indices)
var lotteryNumbers = [];
var currentLotteryDisplayed = [];

var lotteries = [];

$(function()
{   
    setAllVisible(false);

    window.addEventListener('message', function(event)
    {
        var item = event.data;

        if(item.type && item.type == "toggleui") {
            if(item.enable){
                setMainVisible(true);
                lotteries = item.lotteries;
                for (var i = 0; i < lotteries.length; i++){
                    $('#lotterySelect').append("<option value='"+i+"' class = 'lotteryListing'>"+lotteries[i][0]+" $"+lotteries[i][5]+"</option>");
                }
            } else {
                setMainVisible(false);
                reset();
            }
        }
    });
});

function closeLottery() {
    $.post('http://s1lent_lottery/s1lent_lottery:close', JSON.stringify({}));
    reset();
}

function redeemTickets() {
    $.post('http://s1lent_lottery/s1lent_lottery:redeem', JSON.stringify({}));
    closeLottery();
}

function buy() {
    if (lotteryNumbers.length < currentLotteryDisplayed[6]){
        // display error message
        var maxNumbers = currentLotteryDisplayed[6];
        if ( maxNumbers == 1){
            $('#lotteryInfo').html("You have to choose "+maxNumbers+" number.");
        }else{
            $('#lotteryInfo').html("You have to choose "+maxNumbers+" numbers.");

        }

        setTimeout(function(){
            $('#lotteryInfo').html("Date/Time: <span id='lotteryPageDateTime'></span><br>Cost: $<span id='lotteryPageCost'></span><br>Choose <span id='lotteryPageNum'></span> numbers. ");
            $('#lotteryPageDateTime').html(currentLotteryDisplayed[4] + " at " + currentLotteryDisplayed[3]);
            $('#lotteryPageCost').html(currentLotteryDisplayed[5]);
            $('#lotteryPageNum').html(currentLotteryDisplayed[6]);
        }, 3000);
        return;
    }

    $.post('http://s1lent_lottery/s1lent_lottery:buy', JSON.stringify({
        uniqueID: currentLotteryDisplayed[1],
        id: currentLotteryDisplayed[2],
        price: currentLotteryDisplayed[5],
        pickedNums: lotteryNumbers
    }));
}

function setAllVisible(bool) {
    setMainVisible(bool);
    setLottoNumbersVisible(bool)
}

function setMainVisible(bool) {
    if(bool) { //Enable ui
        $('#container').show();
    } else { //Disable ui
        $('#container').hide();
    }
}

function setLottoNumbersVisible(bool) {
    if(bool) { //Enable ui
        $('#lottoNumbers').show();
    } else { //Disable ui
        $('#lottoNumbers').hide();
    }
}

var lotteryDisplay = $('#lotteryPage');
var mainDisplay = $('#mainPage');

function reset(){
    showHome();
    lotteryNumbers = [];
    currentLotteryDisplayed = [];
    lotteries = []
    var container = document.getElementById("lotterySelect");
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }
}

function toggleLottery(){
    if (lotteryDisplay.css('display') == 'none'){
        showLottery();
    } else{
        hideLottery();
    }
}

function showLottery(){
    var lotteryNumber = parseInt($('#lotterySelect').val());
    currentLotteryDisplayed = lotteries[lotteryNumber];
    addNumbers(document.getElementById('numberContainer'), currentLotteryDisplayed[7], currentLotteryDisplayed[8]);

    $('#lotteryPageName').html(currentLotteryDisplayed[0]);
    $('#lotteryPageDateTime').html(currentLotteryDisplayed[4] + " at " + currentLotteryDisplayed[3]); 
    $('#lotteryPageCost').html(currentLotteryDisplayed[5]);
    $('#lotteryPageNum').html(currentLotteryDisplayed[6]);

    lotteryDisplay.show();
    mainDisplay.hide();
}

function hideLottery(){
    var container = document.getElementById("numberContainer");
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }
    lotteryDisplay.hide();
    currentLotteryDisplayed = null;
    lotteryNumbers = []
}

function showHome(){
    hideLottery();
    mainDisplay.show();
}

function addNumbers(element, low, high){
    for (var i = low; i < high + 1; i++){
        var number = document.createElement("span");
        number.textContent = i;
        number.setAttribute('id', 'number' + i);
        number.setAttribute('class', 'numberDisplay');
        number.setAttribute('onclick', 'selectNumber('+i+')');
        element.appendChild(number);
    }
    element.setAttribute('class', '');
    if ((high - low) < 15){
        element.setAttribute('class', 'smallCount');
    }
}

function selectNumber(number){
    //console.log(number); //debug
    if (lotteryNumbers.includes(number)){
        lotteryNumbers = lotteryNumbers.filter(function(num){
            return num != number;
        });
        $('#number'+number).removeClass('selectedNumber');
        //console.log(lotteryNumbers); //debug
        return;
    }
    
    if (lotteryNumbers.length >= currentLotteryDisplayed[6]){
        // display error message
        var maxNumbers = currentLotteryDisplayed[6];
        if ( maxNumbers == 1){
            $('#lotteryInfo').html("You can only choose "+maxNumbers+" number.");
        }else{
            $('#lotteryInfo').html("You can only choose "+maxNumbers+" numbers.");

        }

        setTimeout(function(){
            $('#lotteryInfo').html("Date/Time: <span id='lotteryPageDateTime'></span><br>Cost: $<span id='lotteryPageCost'></span><br>Choose <span id='lotteryPageNum'></span> numbers. ");
            $('#lotteryPageDateTime').html(currentLotteryDisplayed[4] + " at " + currentLotteryDisplayed[3]);
            $('#lotteryPageCost').html(currentLotteryDisplayed[5]);
            $('#lotteryPageNum').html(currentLotteryDisplayed[6]);
        }, 3000);
        return;
    }
    
    lotteryNumbers.push(number);
    $('#number'+number).addClass('selectedNumber');
    
    lotteryNumbers.sort();

    //console.log(lotteryNumbers); //debug
}