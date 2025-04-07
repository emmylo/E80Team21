int main() {
    int R1 = 6000;

    // get R1 into range
    while (R1 >= 6000 || R1 <= 4000) {
        if (R1 > 6000) {
            R1 -= 1000;  // Decrease R1 by 1000 if it's greater than 6000
        } else {
            R1 += 1000;  // Increase R1 by 1000 if it's less than 4000
        }
    }


}