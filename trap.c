#include <stdio.h>
#include <stdint.h>
#include <memory.h>

#define MIN(x, y) ((x) < (y) ? (x) : (y))
#define MAX(x, y) ((x) > (y) ? (x) : (y))

typedef uint64_t uint64;
typedef uint8_t uint8;
typedef enum { false, true } bool;

// TODO:
// handle cost
// more mutations

typedef enum __attribute__((packed)) {
        NONE,
        FIRE,
        FROST,
        POISON,
        LIGHTNING,
        STRENGTH,  // white
        CONDENSER, // pink
        KNOWLEDGE, // cyan
} trap;

static uint64 colors[] = { 0, 41, 44, 42, 43, 47, 45, 46 };

static uint64 costs[8][100] = {
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 100, 150, 225, 337, 506, 759, 1139, 1708, 2562, 3844, 5766, 8649, 12974, 19461, 29192, 43789, 65684, 98526, 147789, 221683, 332525, 498788, 748182, 1122274, 1683411, 2525116, 3787675, 5681512, 8522269, 12783403, 19175105, 28762658, 43143988, 64715982, 97073973, 145610960, 218416440, 327624661, 491436992, 737155488, 1105733232, 1658599848, 2487899772, 3731849658, 5597774487, 8396661731, 12594992596, 18892488895, 28338733342, 42508100014, 63762150021, 95643225032, 143464837548, 215197256322, 322795884483, 484193826725, 726290740087, 1089436110131, 1634154165197, 2451231247795, 3676846871693, 5515270307539, 8272905461309, 12409358191964, 18614037287947, 27921055931921, 41881583897881, 62822375846822, 94233563770233, 141350345655350, 212025518483025, 318038277724537, 477057416586806, 715586124880210, 1073379187320315, 1610068780980472, 2415103171470709, 3622654757206063, 5433982135809095, 8150973203713642, 12226459805570464, 18339689708355696, 27509534562533544, 41264301843800312, 61896452765700472, 92844679148550720, 139267018722826048, 208900528084239100, 313350792126358656, 470026188189538000, 705039282284306900, 1057558923426460416, 1586338385139690496, 2379507577709536256, 3569261366564303872, 5353892049846456320, 8030838074769683456, 12046257112154525696u, 18069385668231788544u, ~0u },
        { 100, 500, 2500, 12500, 62500, 312500, 1562500, 7812500, 39062500, 195312500, 976562500, 4882812500, 24414062500, 122070312500, 610351562500, 3051757812500, 15258789062500, 76293945312500, 381469726562500, 1907348632812500, 9536743164062500, 47683715820312500, 238418579101562500, 1192092895507812352, 5960464477539062784u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u },
        { 500, 875, 1531, 2679, 4689, 8206, 14361, 25132, 43981, 76968, 134694, 235715, 412502, 721879, 1263288, 2210755, 3868822, 6770439, 11848268, 20734469, 36285321, 63499313, 111123797, 194466646, 340316630, 595554103, 1042219681, 1823884442, 3191797774, 5585646105, 9774880683, 17106041196, 29935572094, 52387251164, 91677689538, 160435956692, 280762924211, 491335117370, 859836455398, 1504713796947, 2633249144657, 4608186003150, 8064325505513, 14112569634648, 24696996860634, 43219744506110, 75634552885694, 132360467549964, 231630818212438, 405353931871766, 709369380775591, 1241396416357285, 2172443728625249, 3801776525094186, 6653108918914825, 11642940608100946, 20375146064176652, 35656505612309140, 62398884821541000, 109198048437696752, 191096584765969312, 334419023340446336, 585233290845781000, 1024158258980116736, 1792276953215204500, 3136484668126607500, 5488848169221564416, 9605484296137736192u, 16809597518241038336u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u },
        { 1000, 3000, 9000, 27000, 81000, 243000, 729000, 2187000, 6561000, 19683000, 59049000, 177147000, 531441000, 1594323000, 4782969000, 14348907000, 43046721000, 129140163000, 387420489000, 1162261467000, 3486784401000, 10460353203000, 31381059609000, 94143178827000, 282429536481000, 847288609443000, 2541865828329000, 7625597484987000, 22876792454961000, 68630377364883000, 205891132094649000, 617673396283947000, 1853020188851841000, 5559060566555523000, 16677181699666567168u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u },
        { 3000, 300000, 30000000, 3000000000, 300000000000, 30000000000000, 3000000000000000, 300000000000000000u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u },
        { 6000, 600000, 60000000, 6000000000, 600000000000, 60000000000000, 6000000000000000, 600000000000000000u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u },
        { 9000, 900000, 90000000, 9000000000, 900000000000, 90000000000000, 9000000000000000, 900000000000000000u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u, ~0u },
};

typedef struct {
        trap traps[100];
        uint8 counts[8];
        uint8 padding[4];
        uint64 damage;
        uint64 cost;
} spire_t;

static spire_t best_spire = {
        // { [ 84 ] = FIRE }, { [NONE] = 84, [FIRE] = 1 }, { 0 }, 0, 0
        {
                NONE, NONE, NONE, FROST, LIGHTNING,
                STRENGTH, FIRE, FIRE, FIRE, FIRE,
                NONE, NONE, NONE, FROST, LIGHTNING,
                STRENGTH, FIRE, FIRE, FIRE, FIRE,
                NONE, NONE, NONE, FROST, LIGHTNING,
                STRENGTH, FIRE, FIRE, FIRE, FIRE,
                NONE, NONE, NONE, FROST, LIGHTNING,
                STRENGTH, FIRE, FIRE, FIRE, FIRE,
                FROST, LIGHTNING, KNOWLEDGE, POISON, POISON,
                POISON, POISON, POISON, POISON, POISON,
                POISON, POISON, POISON, FROST, LIGHTNING,
                KNOWLEDGE, LIGHTNING, CONDENSER, LIGHTNING, CONDENSER,
                LIGHTNING, CONDENSER, LIGHTNING, CONDENSER, FIRE,
                LIGHTNING, FROST, KNOWLEDGE, FIRE, FIRE,
                FIRE, FIRE, FIRE, FIRE, FIRE,
                FIRE, FIRE, LIGHTNING, FROST, KNOWLEDGE,
                FIRE, FIRE, FIRE, FIRE, FIRE,
        }, { 12, 31, 8, 10, 12, 4, 4, 4 }, { 0 }, 0, 0
};

static spire_t spire;

static uint64 rng(void)
{
        static uint64 state = 42;
        state ^= state << 13;
        state ^= state >> 7;
        state ^= state << 17;
        return state;
}

static void mutate(void)
{
        uint64 src;
        uint64 dest;
        uint64 trap;

        switch (rng() % 6) {

        case 0: // swap two traps
                do {
                        src = rng() % 84;
                        dest = rng() % 84;
                } while (spire.traps[dest] == spire.traps[src]);
                trap = spire.traps[dest];
                spire.traps[dest] = spire.traps[src];
                spire.traps[src] = trap;
                break;

        case 1: // move a trap earlier
                src = rng() % 82 + 2;
                dest = rng() % (src - 1);
                trap = spire.traps[src];
                memmove(spire.traps + dest + 1, spire.traps + dest, src - dest);
                spire.traps[dest] = trap;
                break;

        case 1: // move a trap later
                src = rng() % 82;
                // TODO TODO
                dest = rng() % (src - 1);
                trap = spire.traps[src];
                memmove(spire.traps + dest + 1, spire.traps + dest, src - dest);
                spire.traps[dest] = trap;
                break;

        case 2: // swap a double row
                src = rng() % 15 * 5;
                dest = rng() % 14 * 5;
                dest += dest >= src ? 5 : 0;
                for (uint64 i = 0; i < 10; ++i) {
                        trap = spire.traps[dest + i];
                        spire.traps[dest + i] = spire.traps[src + i];
                        spire.traps[src + i] = trap;
                }
                break;

        case 3: // replace a trap
        case 4: // replace a trap
                src = rng() % 84;
                --spire.counts[spire.traps[src]];
                do {
                        trap = rng() % 7 + 1;
                } while (trap > 4 && spire.counts[trap] >= 4);
                ++spire.counts[trap];
                spire.traps[src] = trap;
                break;

        }
}

static bool can_kill(uint64 max_hp)
{
        uint64 damage = 0;
        uint64 poison = 0;
        uint64 delay = 0;
        uint64 shocked = 0;
        uint64 chilled = 0;
        uint64 frozen = 0;

        uint64 cell = 0;

        while (cell < 85) {
                uint64 effect_mult = shocked ? 2 : 1;
                uint64 damage_mult = shocked ? 4 : 1;
                shocked -= shocked ? 1 : 0;

                if (delay) {
                        --delay;
                } else {
                        ++cell;
                        if (frozen) {
                                delay = 2;
                                --frozen;
                        } else if (chilled) {
                                delay = 1;
                                --chilled;
                        }
                }

                switch (spire.traps[cell]) {

                case FIRE:
                        damage += (chilled ? 125000 : 100000) * damage_mult
                                * (spire.traps[cell - cell % 5] == STRENGTH ? 2 : 1);
                        break;

                case FROST:
                        damage += 125000 * damage_mult;
                        chilled = 5 * effect_mult;
                        frozen = 0;
                        delay = 0;
                        break;

                case POISON:
                        poison += 40 * damage_mult
                                * (damage > max_hp / 4 ? 5 : 1)
                                * (cell > 0 && spire.traps[cell - 1] == POISON ? 3 : 1)
                                * (spire.traps[cell + 1] == POISON ? 3 : 1)
                                * (spire.traps[cell + 1] == FROST ? 4 : 1);
                        break;

                case LIGHTNING:
                        damage += 5000 * damage_mult;
                        shocked = 2;
                        break;

                case CONDENSER:
                        poison += (poison / 4) * effect_mult;
                        break;

                case KNOWLEDGE:
                        if (chilled) {
                                frozen = 5 * effect_mult;
                                chilled = 0;
                                delay = 0;
                        }
                        break;

                case STRENGTH:
                        damage += (chilled ? 250000 : 200000) * damage_mult * (
                                (spire.traps[cell + 1] == FIRE) +
                                (spire.traps[cell + 2] == FIRE) +
                                (spire.traps[cell + 3] == FIRE) +
                                (spire.traps[cell + 4] == FIRE)
                        );
                        break;

                case NONE:
                        break;
                }

                damage += poison;
        }

        return damage * 5 >= max_hp * 4;
}

uint64 compute_damage()
{
        uint64 damage = 0;
        uint64 bit = 0;

        while (can_kill(damage + (1 << bit)))
                damage += 1 << bit++;

        while (bit--)
                damage += can_kill(damage + (1 << bit)) << bit;

        return damage;
}

int main(void)
{
        spire = best_spire;
        uint64 best_damage = compute_damage();

        for (uint64 age = 0; age < 1048576; ++age) {
                spire = best_spire;
                uint64 mutation_count = rng() % 8 + 1;

                for (uint64 mut = 0; mut < mutation_count; ++mut) {
                        mutate();
                }

                if (can_kill(best_damage + 1)) {
                        best_spire = spire;
                        best_damage = compute_damage();
                        printf("%ld (%ld)\n", best_damage, mutation_count);
                        age = 0;
                }
        }

        for (uint64 pos = 0; pos < 85; ++pos) {
                printf("\e[%ldm   ", colors[best_spire.traps[80 - pos + 2 * (pos % 5)]]);
                if (pos % 5 == 4)
                        printf("\e[m\n");
        }

        return 0;
}

//  gcc -Wall -Wextra -O3 -std=c99 trap.c
