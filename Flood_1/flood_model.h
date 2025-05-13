#include <string.h>
void add_vectors(double *v1, double *v2, int size, double *result) {
    for(int i = 0; i < size; ++i)
        result[i] = v1[i] + v2[i];
}
void mul_vector_number(double *v1, double num, int size, double *result) {
    for(int i = 0; i < size; ++i)
        result[i] = v1[i] * num;
}
void score(double * input, double * output) {
    double var0[2];
    double var1[2];
    double var2[2];
    double var3[2];
    double var4[2];
    double var5[2];
    double var6[2];
    double var7[2];
    double var8[2];
    double var9[2];
    double var10[2];
    double var11[2];
    double var12[2];
    double var13[2];
    double var14[2];
    double var15[2];
    if (input[3] <= 822.0) {
        if (input[0] <= 6.612023115158081) {
            memcpy(var15, (double[]){1.0, 0.0}, 2 * sizeof(double));
        } else {
            if (input[0] <= 6.892503976821899) {
                memcpy(var15, (double[]){0.0, 1.0}, 2 * sizeof(double));
            } else {
                if (input[1] <= 27.83059787750244) {
                    memcpy(var15, (double[]){0.7903225806451613, 0.20967741935483872}, 2 * sizeof(double));
                } else {
                    memcpy(var15, (double[]){0.9701492537313433, 0.029850746268656716}, 2 * sizeof(double));
                }
            }
        }
    } else {
        memcpy(var15, (double[]){0.0, 1.0}, 2 * sizeof(double));
    }
    double var16[2];
    if (input[5] <= 0.43954119086265564) {
        if (input[2] <= 85.52120971679688) {
            if (input[0] <= 6.874497890472412) {
                if (input[0] <= 6.611862897872925) {
                    memcpy(var16, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var16, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            } else {
                if (input[0] <= 11.71799373626709) {
                    memcpy(var16, (double[]){0.9736842105263158, 0.02631578947368421}, 2 * sizeof(double));
                } else {
                    memcpy(var16, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            }
        } else {
            if (input[5] <= 0.015001873485744) {
                memcpy(var16, (double[]){0.0, 1.0}, 2 * sizeof(double));
            } else {
                memcpy(var16, (double[]){1.0, 0.0}, 2 * sizeof(double));
            }
        }
    } else {
        if (input[3] <= 656.0) {
            if (input[3] <= 628.0) {
                if (input[3] <= 343.0) {
                    memcpy(var16, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var16, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            } else {
                memcpy(var16, (double[]){1.0, 0.0}, 2 * sizeof(double));
            }
        } else {
            memcpy(var16, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    }
    add_vectors(var15, var16, 2, var14);
    double var17[2];
    if (input[3] <= 822.0) {
        if (input[5] <= 0.5188690721988678) {
            if (input[5] <= 0.4541071653366089) {
                if (input[5] <= 0.010910776909440756) {
                    memcpy(var17, (double[]){0.8333333333333334, 0.16666666666666666}, 2 * sizeof(double));
                } else {
                    memcpy(var17, (double[]){0.983739837398374, 0.016260162601626018}, 2 * sizeof(double));
                }
            } else {
                if (input[1] <= 23.88493061065674) {
                    memcpy(var17, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var17, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            }
        } else {
            memcpy(var17, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    } else {
        memcpy(var17, (double[]){0.0, 1.0}, 2 * sizeof(double));
    }
    add_vectors(var14, var17, 2, var13);
    double var18[2];
    if (input[5] <= 0.5162530541419983) {
        if (input[0] <= 3.077887237071991) {
            memcpy(var18, (double[]){0.0, 1.0}, 2 * sizeof(double));
        } else {
            if (input[2] <= 83.88445663452148) {
                if (input[0] <= 11.71799373626709) {
                    memcpy(var18, (double[]){0.96, 0.04}, 2 * sizeof(double));
                } else {
                    memcpy(var18, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            } else {
                if (input[2] <= 87.3001823425293) {
                    memcpy(var18, (double[]){0.25, 0.75}, 2 * sizeof(double));
                } else {
                    memcpy(var18, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            }
        }
    } else {
        memcpy(var18, (double[]){0.0, 1.0}, 2 * sizeof(double));
    }
    add_vectors(var13, var18, 2, var12);
    double var19[2];
    if (input[5] <= 0.5162530541419983) {
        if (input[3] <= 362.5) {
            if (input[0] <= 11.833295822143555) {
                if (input[1] <= 22.95661163330078) {
                    memcpy(var19, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var19, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            } else {
                memcpy(var19, (double[]){1.0, 0.0}, 2 * sizeof(double));
            }
        } else {
            if (input[3] <= 534.5) {
                if (input[0] <= 14.869575023651123) {
                    memcpy(var19, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var19, (double[]){0.9090909090909091, 0.09090909090909091}, 2 * sizeof(double));
                }
            } else {
                memcpy(var19, (double[]){1.0, 0.0}, 2 * sizeof(double));
            }
        }
    } else {
        memcpy(var19, (double[]){0.0, 1.0}, 2 * sizeof(double));
    }
    add_vectors(var12, var19, 2, var11);
    double var20[2];
    if (input[3] <= 822.0) {
        if (input[5] <= 0.5162530541419983) {
            if (input[2] <= 85.52120971679688) {
                memcpy(var20, (double[]){1.0, 0.0}, 2 * sizeof(double));
            } else {
                if (input[1] <= 27.161264419555664) {
                    memcpy(var20, (double[]){0.5714285714285714, 0.42857142857142855}, 2 * sizeof(double));
                } else {
                    memcpy(var20, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            }
        } else {
            memcpy(var20, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    } else {
        memcpy(var20, (double[]){0.0, 1.0}, 2 * sizeof(double));
    }
    add_vectors(var11, var20, 2, var10);
    double var21[2];
    if (input[4] <= 0.5) {
        if (input[1] <= 37.02221870422363) {
            if (input[0] <= 3.967077851295471) {
                memcpy(var21, (double[]){0.0, 1.0}, 2 * sizeof(double));
            } else {
                if (input[5] <= 0.8577035963535309) {
                    memcpy(var21, (double[]){0.9775280898876404, 0.02247191011235955}, 2 * sizeof(double));
                } else {
                    memcpy(var21, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            }
        } else {
            if (input[0] <= 6.631444692611694) {
                memcpy(var21, (double[]){0.0, 1.0}, 2 * sizeof(double));
            } else {
                if (input[3] <= 623.0) {
                    memcpy(var21, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var21, (double[]){0.8, 0.2}, 2 * sizeof(double));
                }
            }
        }
    } else {
        if (input[3] <= 822.0) {
            if (input[2] <= 88.89788055419922) {
                if (input[5] <= 0.1450042426586151) {
                    memcpy(var21, (double[]){0.875, 0.125}, 2 * sizeof(double));
                } else {
                    memcpy(var21, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            } else {
                if (input[5] <= 0.6846676431596279) {
                    memcpy(var21, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var21, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            }
        } else {
            memcpy(var21, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    }
    add_vectors(var10, var21, 2, var9);
    double var22[2];
    if (input[5] <= 0.5162530541419983) {
        if (input[4] <= 0.5) {
            if (input[3] <= 745.5) {
                if (input[2] <= 35.14224624633789) {
                    memcpy(var22, (double[]){0.9285714285714286, 0.07142857142857142}, 2 * sizeof(double));
                } else {
                    memcpy(var22, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            } else {
                if (input[2] <= 85.48597717285156) {
                    memcpy(var22, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var22, (double[]){0.25, 0.75}, 2 * sizeof(double));
                }
            }
        } else {
            if (input[3] <= 822.0) {
                if (input[2] <= 64.27004623413086) {
                    memcpy(var22, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var22, (double[]){0.8461538461538461, 0.15384615384615385}, 2 * sizeof(double));
                }
            } else {
                memcpy(var22, (double[]){0.0, 1.0}, 2 * sizeof(double));
            }
        }
    } else {
        memcpy(var22, (double[]){0.0, 1.0}, 2 * sizeof(double));
    }
    add_vectors(var9, var22, 2, var8);
    double var23[2];
    if (input[2] <= 75.001953125) {
        if (input[3] <= 822.0) {
            if (input[1] <= 37.24597930908203) {
                if (input[5] <= 0.5162530541419983) {
                    memcpy(var23, (double[]){0.9746835443037974, 0.02531645569620253}, 2 * sizeof(double));
                } else {
                    memcpy(var23, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            } else {
                memcpy(var23, (double[]){1.0, 0.0}, 2 * sizeof(double));
            }
        } else {
            memcpy(var23, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    } else {
        if (input[3] <= 809.5) {
            if (input[1] <= 24.561245918273926) {
                if (input[5] <= 0.8618751019239426) {
                    memcpy(var23, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var23, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            } else {
                if (input[1] <= 39.95521926879883) {
                    memcpy(var23, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var23, (double[]){0.8333333333333334, 0.16666666666666666}, 2 * sizeof(double));
                }
            }
        } else {
            memcpy(var23, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    }
    add_vectors(var8, var23, 2, var7);
    double var24[2];
    if (input[3] <= 822.0) {
        if (input[3] <= 534.5) {
            if (input[5] <= 0.8762646615505219) {
                if (input[5] <= 0.013356838375329971) {
                    memcpy(var24, (double[]){0.375, 0.625}, 2 * sizeof(double));
                } else {
                    memcpy(var24, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            } else {
                memcpy(var24, (double[]){0.0, 1.0}, 2 * sizeof(double));
            }
        } else {
            if (input[5] <= 0.896531492471695) {
                if (input[5] <= 0.4541071653366089) {
                    memcpy(var24, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var24, (double[]){0.875, 0.125}, 2 * sizeof(double));
                }
            } else {
                memcpy(var24, (double[]){0.0, 1.0}, 2 * sizeof(double));
            }
        }
    } else {
        memcpy(var24, (double[]){0.0, 1.0}, 2 * sizeof(double));
    }
    add_vectors(var7, var24, 2, var6);
    double var25[2];
    if (input[0] <= 5.093669652938843) {
        memcpy(var25, (double[]){0.0, 1.0}, 2 * sizeof(double));
    } else {
        if (input[4] <= 0.5) {
            if (input[2] <= 27.39896297454834) {
                if (input[3] <= 702.0) {
                    memcpy(var25, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var25, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            } else {
                if (input[5] <= 1.0331120789051056) {
                    memcpy(var25, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var25, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            }
        } else {
            if (input[2] <= 75.2630615234375) {
                if (input[5] <= 0.1450042426586151) {
                    memcpy(var25, (double[]){0.8571428571428571, 0.14285714285714285}, 2 * sizeof(double));
                } else {
                    memcpy(var25, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            } else {
                if (input[2] <= 90.75466537475586) {
                    memcpy(var25, (double[]){0.375, 0.625}, 2 * sizeof(double));
                } else {
                    memcpy(var25, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            }
        }
    }
    add_vectors(var6, var25, 2, var5);
    double var26[2];
    if (input[5] <= 0.5188690721988678) {
        if (input[0] <= 19.303584098815918) {
            if (input[5] <= 0.011287723202258348) {
                if (input[1] <= 35.4196662902832) {
                    memcpy(var26, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var26, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            } else {
                if (input[2] <= 64.34199523925781) {
                    memcpy(var26, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var26, (double[]){0.9761904761904762, 0.023809523809523808}, 2 * sizeof(double));
                }
            }
        } else {
            if (input[2] <= 66.33734130859375) {
                memcpy(var26, (double[]){1.0, 0.0}, 2 * sizeof(double));
            } else {
                if (input[2] <= 90.76490020751953) {
                    memcpy(var26, (double[]){0.0, 1.0}, 2 * sizeof(double));
                } else {
                    memcpy(var26, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            }
        }
    } else {
        memcpy(var26, (double[]){0.0, 1.0}, 2 * sizeof(double));
    }
    add_vectors(var5, var26, 2, var4);
    double var27[2];
    if (input[0] <= 4.970229625701904) {
        memcpy(var27, (double[]){0.0, 1.0}, 2 * sizeof(double));
    } else {
        if (input[0] <= 19.303584098815918) {
            if (input[2] <= 90.62238311767578) {
                if (input[5] <= 0.896531492471695) {
                    memcpy(var27, (double[]){0.9916666666666667, 0.008333333333333333}, 2 * sizeof(double));
                } else {
                    memcpy(var27, (double[]){0.0, 1.0}, 2 * sizeof(double));
                }
            } else {
                if (input[2] <= 90.94540405273438) {
                    memcpy(var27, (double[]){0.0, 1.0}, 2 * sizeof(double));
                } else {
                    memcpy(var27, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            }
        } else {
            if (input[2] <= 66.33734130859375) {
                memcpy(var27, (double[]){1.0, 0.0}, 2 * sizeof(double));
            } else {
                memcpy(var27, (double[]){0.0, 1.0}, 2 * sizeof(double));
            }
        }
    }
    add_vectors(var4, var27, 2, var3);
    double var28[2];
    if (input[2] <= 75.001953125) {
        if (input[0] <= 4.970229625701904) {
            memcpy(var28, (double[]){0.0, 1.0}, 2 * sizeof(double));
        } else {
            if (input[3] <= 604.5) {
                memcpy(var28, (double[]){1.0, 0.0}, 2 * sizeof(double));
            } else {
                if (input[2] <= 35.14224624633789) {
                    memcpy(var28, (double[]){0.7777777777777778, 0.2222222222222222}, 2 * sizeof(double));
                } else {
                    memcpy(var28, (double[]){0.9782608695652174, 0.021739130434782608}, 2 * sizeof(double));
                }
            }
        }
    } else {
        if (input[3] <= 807.5) {
            if (input[5] <= 0.6155554056167603) {
                if (input[3] <= 534.5) {
                    memcpy(var28, (double[]){0.8, 0.2}, 2 * sizeof(double));
                } else {
                    memcpy(var28, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            } else {
                memcpy(var28, (double[]){0.0, 1.0}, 2 * sizeof(double));
            }
        } else {
            memcpy(var28, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    }
    add_vectors(var3, var28, 2, var2);
    double var29[2];
    if (input[2] <= 75.001953125) {
        if (input[3] <= 819.0) {
            if (input[2] <= 37.77845001220703) {
                if (input[2] <= 34.36435127258301) {
                    memcpy(var29, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var29, (double[]){0.25, 0.75}, 2 * sizeof(double));
                }
            } else {
                if (input[0] <= 12.689558506011963) {
                    memcpy(var29, (double[]){1.0, 0.0}, 2 * sizeof(double));
                } else {
                    memcpy(var29, (double[]){0.9555555555555556, 0.044444444444444446}, 2 * sizeof(double));
                }
            }
        } else {
            memcpy(var29, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    } else {
        if (input[3] <= 818.0) {
            if (input[5] <= 0.45252054929733276) {
                if (input[3] <= 534.5) {
                    memcpy(var29, (double[]){0.875, 0.125}, 2 * sizeof(double));
                } else {
                    memcpy(var29, (double[]){1.0, 0.0}, 2 * sizeof(double));
                }
            } else {
                memcpy(var29, (double[]){0.0, 1.0}, 2 * sizeof(double));
            }
        } else {
            memcpy(var29, (double[]){0.0, 1.0}, 2 * sizeof(double));
        }
    }
    add_vectors(var2, var29, 2, var1);
    mul_vector_number(var1, 0.06666666666666667, 2, var0);
    memcpy(output, var0, 2 * sizeof(double));
}
