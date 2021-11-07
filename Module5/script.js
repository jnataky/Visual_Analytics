{
    const presidents = document.querySelector('#presidents');
    const csvUrl = "https://raw.githubusercontent.com/jnataky/Visual_Analytics/main/Module5/Data/president.csv";
    d3.csv(csvUrl).then(function (data) {
        let table = '<table>';
        table += '<tr>';
        for (let j = 0; j < data.columns.length; j++) {
            table += '<td>' + data.columns[j] + '</td>';
        }
        table += '</tr>';

        for (let i = 0; i < data.length; i++) {
            table += '<tr>';
            for (let j = 0; j < data.columns.length; j++) {
                table += '<td>' + data[i][data.columns[j]] + '</td>';
            }
            table += '</tr>';
        }
        table += '</table>';
        presidents.innerHTML = table;
    });
}


{
    const input = document.querySelector('#president-input');
    const button = document.querySelector('#get-president');
    const result = document.querySelector('#president-data');
    const csvUrl = "https://raw.githubusercontent.com/jnataky/Visual_Analytics/main/Module5/Data/president.csv";
    let presidentsData;

    d3.csv(csvUrl).then(function (data) {
        presidentsData = data;
    });

    button.onclick = () => {
        const name = input.value;
        let data = null;
        for (let i = 0; i < presidentsData.length; i++) {
            if (presidentsData[i].Name === name) {
                data = presidentsData[i];
                break;
            }
        }
        if (data) {
            result.innerHTML = `Weight: ${data['Weight']}; Height: ${data['Height']}`;
        }
        else {
            result.innerHTML = 'Please enter the correct name';
        }
    };
}