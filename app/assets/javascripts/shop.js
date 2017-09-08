// change shirt color
$(".ui.dropdown.sweatshirt")
    .dropdown({
        onChange: function (value) {
            if (value == 0) {
                $(".hoodie").show();
                $(".crewneck").hide();
            }
            if (value == 1) {
                $(".hoodie").hide();
                $(".crewneck").show();
            }
        }
    })
;

//lazy load
$("img").lazyload({
    threshold : 300
});

//change shirt color
$('.colorBtn').hover(function () {
    $(this).children().eq(1).toggleClass("open");
});

$('.designBtn').hover(function () {
    $(this).children().eq(1).toggleClass("open");
});

$('.sf-su-response.open').hover(function (){
    $(this).toggleClass("open");
});

$(".black").click(function () {
    var white = $(this).parent().parent().parent().parent().children().find('.white-shirt');
    var gray = $(this).parent().parent().parent().parent().children().find('.gray-shirt');
    var black = $(this).parent().parent().parent().parent().children().find('.black-shirt');

    $(white).attr('style', 'display:none !important');
    $(gray).attr('style', 'display:none !important');
    $(black).attr('style', 'display:block !important');

    console.log($(this).parent().parent().children());
    $(this).parent().parent().children().eq(0).attr('class', 'select color black colorBtn');

});

$(".white").click(function () {
    var white = $(this).parent().parent().parent().parent().children().find('.white-shirt');
    var gray = $(this).parent().parent().parent().parent().children().find('.gray-shirt');
    var black = $(this).parent().parent().parent().parent().children().find('.black-shirt');

    $(white).attr('style', 'display:block !important');
    $(gray).attr('style', 'display:none !important');
    $(black).attr('style', 'display:none !important');

    $(this).parent().parent().children().eq(0).attr('class', 'select color white colorBtn');
});

$(".gray").click(function () {
    var white = $(this).parent().parent().parent().parent().children().find('.white-shirt');
    var gray = $(this).parent().parent().parent().parent().children().find('.gray-shirt');
    var black = $(this).parent().parent().parent().parent().children().find('.black-shirt');

    $(white).attr('style', 'display:none !important');
    $(gray).attr('style', 'display:block !important');
    $(black).attr('style', 'display:none !important');

    $(this).parent().parent().children().eq(0).attr('class', 'select color gray colorBtn');
});