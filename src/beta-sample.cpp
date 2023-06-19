// beta-sample.cpp
#include <iostream>
#include <random>

void print_message(double value, double a, double b) {
    std::cout << "beta(" << a << "," << b << ") sample: " << value << std::endl;
}

std::vector<double> draw_betas(int n, double a, double b) {
    // gamma distributions
    std::gamma_distribution<double> gamma_a(a, 1.0);
    std::gamma_distribution<double> gamma_b(b, 1.0);

    // mersenne twister numbers
    std::random_device rd;
    std::mt19937 mt(rd());

    // draw samples and return
    std::vector<double> beta_variates;
    double x, y;
    for (int i = 0; i < n; i++) {
        x = gamma_a(mt);
        y = gamma_b(mt);
        beta_variates[i] = x / (x + y);
    }
    return beta_variates;
}

int main() {
    const double a = 2.0; // shape parameter 1
    const double b = 1.0; // shape parameter 2
    const int n = 5; // length of output vector

    // draw samples
    std::vector<double> betas = draw_betas(n, a, b);

    // print messages and return
    for (int i = 0; i < n; i++) {
        print_message(betas[i], a, b);
    }
    return 0;
}

