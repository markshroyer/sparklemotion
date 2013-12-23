function setColor(color) {
    $.ajax({
        url: '/color',
        type: 'PUT',
        contentType: 'text/plain',
        data: color
    });
}

$(document).ready(function () {
    $('button[name="red"]').click(function () {
        setColor('#ff0000');
    });
    $('button[name="green"]').click(function () {
        setColor('#00ff00');
    });
    $('button[name="blue"]').click(function () {
        setColor('#0000ff');
    });
});
