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
        controls: {
            horiz: 's',
            vert: 'v',
            strip: 'h'
        },
        change: function(event, ui) {
            setColor(ui.color.toString());
        }
    });
});
