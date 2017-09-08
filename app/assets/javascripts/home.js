/**
 * Created by mattvitello on 5/16/17.
 */
$(document).on("click",".hot-home-container",function(){
   window.location.href = '/hot'
});

$(document).on("click",".new-home-container",function(){
    window.location.href = '/new'
});

$(document).on("click",".top-home-container",function(){
    window.location.href = '/top'
});

// $(window).scroll(function() {
//     $('.feed').slideDown('slow');
// });

$(document).ready(function(){
    $grid = $('.grid').packery({
        itemSelector: '.grid-item',
        gutter: '.gutter-sizer',
        percentPosition: true,
        columnWidth: '.grid-sizer',
        transitionDuration: '1.2s'
    });

    random_top();

    // $(".grid").mouseover(function(){
    //    $('.feed').slideDown('slow');
    // });
})

setInterval(function(){
    random_top();
}, 7000);

function random_top() {
    var url = "/tweet/random_top.json";
    var namelist = [];

    $.ajax(url, {
        datatype: "json",
        contentType: "application/json; charset=utf-8",
        type: "GET",
        data: {}
        ,
        success: function (data) {

            var tweets = data;

            if($.inArray(tweets[3], namelist) == -1){

                namelist.push(tweets[3]);
                tweets[4] = tweets[4].replace(/_normal/gi, "");
                tweets[1] = urlify(tweets[1]);
                console.log(tweets);

                // create new item elements
                var $items = $('<div class="grid-item">' +
                    '<div class="twitter twitter-image"><img src="' + data[4] + '" style="width:100%; height:100%"></div>' +
                    '<div class="twitter twitter-name">' + data[2] + '</div>' +
                    '<div class="twitter twitter-user">@' + data[3] + '</div>' +
                    '<img src="/images/twitter-xxl.png" class="twitter-logo">' +
                    '<div class="twitter twitter-text">' + data[1] + '</div>' +

                    '</div>');
                // prepend items to grid
                window.setTimeout(function(){
                    if( $(".grid-item").length >= 3){
                        $('.grid .grid-item:last').remove()
                        $('.grid').prepend($items).packery('prepended', $items);
                    }
                    else{
                        $('.grid').prepend($items).packery('prepended', $items);
                    }
                },1200);

            }
            else{
                random_top();
                alert();
            }

        },
        error: function (data) {
            random_top();
        }
    });
}

function urlify(text) {
    var urlRegex = /(https?:\/\/[^\s]+)/g;
    return text.replace(urlRegex, '<a href="$1" style="color: #505c7a;">$1</a>')
}