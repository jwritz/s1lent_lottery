var buttons = [];
var selectedCount = 0;

// These counts are the number of numbers show for a lottery
// in the order they appear in the dropdown menu.
// (Zero based indices)
var lotteryNumbers = [];
var currentLotteryDisplayed = [];

var lotteries = [];
var ticketList = [];

$(function()
{   
    setAllVisible(false);

    $('#prizeBtn').mouseenter(function(){
        showPrizes();
    });

    $('#prizeBtn').mouseleave(function(){
        hidePrizes();
    });

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
        } else if (item.type && item.type == "getTicketList") {
            ticketList = item.ticketList 
            updateTicketTable();
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

function updateTickets() {
    $.post('http://s1lent_lottery/s1lent_lottery:getTicketList', JSON.stringify({}));
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
        pickedNums: lotteryNumbers,
        date: currentLotteryDisplayed[4],
        time: currentLotteryDisplayed[3]
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

var mainDisplay = $('#mainPage');
var lotteryDisplay = $('#lotteryPage');
var myTicketsDisplay = $('#myTicketsPage');

function reset(){
    showHome();
    lotteryNumbers = [];
    currentLotteryDisplayed = [];
    lotteries = []
    ticketList = []
    var container = document.getElementById("lotterySelect");
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }
    var container = document.getElementById("myTicketTable");
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }
    $('#myTicketTable').append("<tr><th style='width:75px;'>Drawing</th><th>Date</th><th>Time</th><th>My Numbers</th><th>Prize</th></tr>");
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

    addPrizes();

    lotteryDisplay.show();
    mainDisplay.hide();
}

function hideLottery(){
    var container = document.getElementById("numberContainer");
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }
    hidePrizes();
    clearPrizes();
    lotteryDisplay.hide();
    currentLotteryDisplayed = null;
    lotteryNumbers = []
}

function showHome(){
    hideLottery();
    hideMyTickets();
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

function showPrizes(){
    // $('#prizes').show();
    $('#prizeList').show();

}

function hidePrizes(){
    // $('#prizes').hide();
    $('#prizeList').hide();
}

function addPrizes(){
    var prizeArray = currentLotteryDisplayed[9];
    var count = prizeArray.length;
    var prizeElement = $('#prizes');
    for (var i = 0; i < count; i++){
        if(i == 0){
            prizeElement.append("<div><div class='prize'>"+(i+1)+" Match:</div>$"+prizeArray[i]+"</div>");
        }else {
            prizeElement.append("<div><div class='prize'>"+(i+1)+" Matches:</div>$"+prizeArray[i]+"</div>");
        }
    }
}

function clearPrizes(){
    $('#prizes').html("");
}

function showMyTickets(){
    updateTickets();
    myTicketsDisplay.show();
    mainDisplay.hide();
}

function hideMyTickets(){
    myTicketsDisplay.hide();
    
    var container = document.getElementById("myTicketTable");
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }
    $('#myTicketTable').append("<tr><th style='width:75px;'>Drawing</th><th>Date</th><th>Time</th><th>My Numbers</th><th>Prize</th></tr>");
}

function updateTicketTable(){
    var ticketTable = $('#myTicketTable');
    var count = ticketList.length;
    for (var i = 0; i < count; i++){
        var drawingName = ticketList[i][0];
        var drawDate = ticketList[i][1];
        var drawTime = ticketList[i][2];
        var pickedNumbers = ticketList[i][3];
        var ticketPrize = ticketList[i][4];
        var rowColor = "#c4ffbc";
        if (ticketPrize == ""){
            rowColor = "#a5c89e";
        }

        ticketTable.append("<tr style='background-color:"+rowColor+"'><td>"+drawingName+"</td><td>"+drawDate+"</td><td>"+drawTime+"</td><td>"+pickedNumbers+"</td><td>"+ticketPrize+"</td></tr>");
    }

}