function setColor(color) {
    $.ajax({
        url: '/color',
        type: 'PUT',
        contentType: 'text/plain',
        data: color
    });
}

$(document).ready(function ($) {
    $('#color-picker').iris({
        hide: false,
        width: 480,
        mode: 'hsv',
        change: function(event, ui) {
            setColor(ui.color.toString());
        }
    });
});
