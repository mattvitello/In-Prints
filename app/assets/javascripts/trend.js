!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");

$(".ui.dropdown.color")
    .dropdown({
        onChange: function (value) {
            if (value == 0) {
                $(".white-shirt").show();
                $(".black-shirt").hide();
                $(".gray-shirt").hide();
            }
            if (value == 1) {
                $(".white-shirt").hide();
                $(".black-shirt").show();
                $(".gray-shirt").hide();
            }
            if (value == 2) {
                $(".white-shirt").hide();
                $(".black-shirt").hide();
                $(".gray-shirt").show();
            }
        }
    })
;

$(".ui.dropdown.design")
    .dropdown({
    })
;

$(".ui.dropdown.size")
    .dropdown({
    })
;