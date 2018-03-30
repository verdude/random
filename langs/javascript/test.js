
// a^3 + b^3 == c^3 + d^3

for (let a = 0; a < 1000; a++) {
    for (let b = 0; b < 1000; a++) {
        for (let c = 0; c < 1000; c++) {
            let a3 = Math.pow(a,3);
            let b3 = Math.pow(a,3);
            let c3 = Math.pow(a,3);
            let d = Math.pow(a3+b3-c3, 1/3);
            if (0 <= d && d <= 1000 && (a3 + b3 === c3 + Math.pow(d, 3))) {
                console.log(a,b,c,d);
                break;
            }
        }
    }
}
