#ifndef RSA64_H
#define RSA64_H

uint16_t add_word(uint16_t *, uint16_t, uint16_t, uint16_t);
uint8_t subtract_word(uint16_t *, uint16_t, uint16_t, uint8_t);
uint16_t add_mp_elements(uint16_t *, uint16_t *, uint16_t *, uint8_t);
uint16_t subtract_mp_elements(uint16_t *, uint16_t *, uint16_t *, uint8_t);
void add_mod_p(uint16_t *, uint16_t *, uint16_t *, uint16_t *, uint8_t);
void subtract_mod_p(uint16_t *, uint16_t *, uint16_t *, uint16_t *, uint8_t);
void set_to_zero(uint16_t *, uint8_t);
void multiply_words(uint16_t, uint16_t, uint16_t *);
void multiply_words_2(uint16_t, uint16_t, uint16_t *);
void multiply_mp_elements(uint16_t *, uint16_t *, uint16_t *, uint8_t);
void multiply_mp_elements2(uint16_t *, uint16_t *, uint8_t, uint16_t *, uint8_t);
void divide_mp_elements(uint16_t *, uint16_t *, uint16_t *, int, uint16_t *, int);
uint8_t compare_mp_elements(uint16_t *, uint16_t *, uint8_t);
void mult_by_power_of_b(uint16_t *, uint16_t, uint16_t *, uint16_t, uint16_t);
void mod_pow_of_b(uint16_t *, uint16_t, uint16_t *, uint16_t, uint16_t);
void div_by_power_of_b(uint16_t *, uint16_t, uint16_t *, uint16_t, uint16_t);
void multiply_sp_by_mp_element(uint16_t *, uint16_t, uint16_t *, uint16_t);
int are_mp_equal(uint16_t *, uint16_t *, uint8_t);
void copy_mp(uint16_t *, uint16_t *, int);
int ith_bit(uint16_t, int);
int bit_length(uint16_t);
int mp_bit_length(uint16_t *, uint16_t);
int mp_ith_bit(uint16_t *, int);
int mp_non_zero_words(uint16_t *, uint16_t);
uint16_t divide_2_word_by_1_word(uint16_t, uint16_t, uint16_t);
uint16_t divide_2_word_by_1_word(uint16_t, uint16_t, uint16_t);


#endif /* RSA64_H */
